import sys
import boto3
from datetime import datetime, timedelta, timezone

if len(sys.argv) != 3:
    print("Usage: python3 this-script.py <ceph_bucket> <days_older_than>")
    sys.exit(1)

ceph_bucket = sys.argv[1]
days = int(sys.argv[2])

# Setup Ceph S3 client. Use bucket names as profile names - check credentials file generation in get-keys.sh
ceph_s3_client = boto3.Session(profile_name=ceph_bucket).client('s3')
response = ceph_s3_client.list_multipart_uploads(
    Bucket=ceph_bucket
)
uploads = response.get('Uploads', [])

# Adjust timezone as needed. Here UTC is used
older_than = datetime.now(timezone.utc) - timedelta(days=days)

if uploads:
    for upload in uploads:
        upload_id = upload.get('UploadId', '')
        key = upload.get('Key', '')
        initiated = upload.get('Initiated', '')
        # Compare upload initiation date to the given retention number of days
        if initiated < older_than:
            print(f"Found multipart upload older than {days} days for {ceph_bucket}.")
            print(f"ID: {upload_id}, Key: {key}, Initiated: {initiated}")
            # Cleanup the upload. Comment/remove below 6 lines if you want just a list of incomplete uploads.
            ceph_s3_client.abort_multipart_upload(
                    Bucket=ceph_bucket,
                    Key=key,
                    UploadId=upload_id
                )
            print(f"Multipart upload {upload_id} for {key} cleaned successfully.")
else: 
    print(f"No uploads older than {days} days for {ceph_bucket} found. Bucket is clean.")
