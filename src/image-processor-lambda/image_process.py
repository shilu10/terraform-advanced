import boto3
import json
import os
import pymysql
from urllib.parse import unquote_plus

s3 = boto3.client('s3')
secretsmanager = boto3.client('secretsmanager')


def get_rds_credentials(secret_name):
    response = secretsmanager.get_secret_value(SecretId=secret_name)
    secret = json.loads(response['SecretString'])
    return secret


def connect_to_rds(creds):
    print(creds)
    return pymysql.connect(
        host=creds["host"],
        user=creds["username"],
        password=creds["password"],
        db=creds["dbname"],
        port=int(creds["port"]),
        connect_timeout=5
    )


def ensure_table_exists(connection):
    with connection.cursor() as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS uploads (
                id INT AUTO_INCREMENT PRIMARY KEY,
                image_key VARCHAR(512) NOT NULL,
                meta JSON,
                uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
    connection.commit()


def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    creds = get_rds_credentials(os.environ["RDS_SECRET_NAME"])
    connection = connect_to_rds(creds)

    # Ensure table exists
    ensure_table_exists(connection)

    for record in event['Records']:
        body = json.loads(record['body'])
        image_key = body['filename']
        metadata  = body['metadata']  # Example: dict of info

        bucket = os.environ["BUCKET_NAME"]
        local_path = f"/tmp/{os.path.basename(image_key)}"
        s3.download_file(bucket, image_key, local_path)

        # Store metadata in RDS
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO uploads (image_key, meta)
                VALUES (%s, %s)
            """, (image_key, json.dumps(metadata)))
        connection.commit()

    connection.close()
    return {"statusCode": 200, "body": "Processed successfully"}
