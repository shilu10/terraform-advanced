import json
import base64
import boto3
import os
import uuid
from datetime import datetime

# Initialize AWS clients
s3 = boto3.client("s3")
sqs = boto3.client("sqs", region_name=os.environ["SQS_REGION"])

# Environment variables
BUCKET_NAME = os.environ["BUCKET_NAME"]
QUEUE_NAME =  os.environ["QUEUE_NAME"]

def lambda_handler(event, context):
    try:
        # Decode request body
        body = base64.b64decode(event["body"]) if event.get("isBase64Encoded") else event["body"].encode()

        # Parse JSON from body
        data = json.loads(body)
        image_base64 = data["image_base64"]
        metadata = data.get("metadata", {})
        user = metadata.get("user", "anonymous")

        # Decode image and generate S3 key
        image_bytes = base64.b64decode(image_base64)
        image_id = str(uuid.uuid4())
        image_key = f"uploads/{image_id}.png"

        # Upload image to S3
        s3.put_object(Bucket=BUCKET_NAME, Key=image_key, Body=image_bytes)
        print(f"Image uploaded to S3: {image_key}")

        # Get the SQS FIFO queue URL
        queue_url = sqs.get_queue_url(QueueName=QUEUE_NAME)["QueueUrl"]

        # Prepare SQS message
        message = {
            "filename": image_key,
            "metadata": {
                "user": user,
                "timestamp": datetime.utcnow().isoformat()
            }
        }

        # Send message to FIFO SQS queue
        sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(message),
            MessageGroupId="uploads",  # Required for FIFO queues
            MessageDeduplicationId=str(uuid.uuid4())  # Required if ContentBasedDeduplication = false
        )
        print("Metadata sent to SQS")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Upload successful", "image_key": image_key})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
