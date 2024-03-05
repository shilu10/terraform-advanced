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
    return pymysql.connect(
        host=creds["host"],
        user=creds["username"],
        password=creds["password"],
        db=creds["dbname"],
        port=int(creds["port"]),
        connect_timeout=5
    )


def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    creds = get_rds_credentials(os.environ["RDS_SECRET_NAME"])
    connection = connect_to_rds(creds)

    for record in event['Records']:
        body = json.loads(record['body'])
        image_key = body['image_key']
        metadata  = body['metadata']  # Example: dict of info

        bucket = os.environ["BUCKET_NAME"]

        # Download image (you could also process here if needed)
        local_path = f"/tmp/{os.path.basename(image_key)}"
        s3.download_file(bucket, image_key, local_path)

        # Store metadata in RDS
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO uploads (image_key, meta)
                VALUES (%s, %s)
            """, (image_key, json.dumps(metadata)))
            connection.commit()

    return {"statusCode": 200, "body": "Processed successfully"}
