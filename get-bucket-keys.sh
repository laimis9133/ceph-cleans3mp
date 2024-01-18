# Generates a credentials file with all Ceph S3 bucket keys to be used with awscli.
# The credentials file needs to be placed as .aws/credentials wherever awscli is installed and bucket names need to be used as profile names!
# It also generates a list of all buckets used for CI. Run this script on Ceph node where radosgw-admin is available

#!/bin/bash

output_file=credentials

buckets_json=$(/usr/bin/radosgw-admin bucket list)
buckets=($(echo "$buckets_json" | jq -r '.[]'))

for bucket in "${buckets[@]}"; do
    echo $bucket >> bucketlist
    owner=$(/usr/bin/radosgw-admin bucket stats --bucket="$bucket" | grep owner | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
    secret_key=$(/usr/bin/radosgw-admin user info --uid="$owner" | grep -A 4 -w keys | grep -w secret_key | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
    access_key=$(/usr/bin/radosgw-admin user info --uid="$owner" | grep -A 4 -w keys | grep -w access_key | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')

    # Append results to console and the credentials file. 
    echo "Bucket: $bucket, Owner: $owner, Secret Key: $secret_key, Access Key: $access_key"

    echo "[$bucket]" >> "$output_file"
    echo "endpoint_url = https://your-ceph.endpoint.com" >> "$output_file" # Set your Ceph endpoint here
    echo "aws_access_key_id = $access_key" >> "$output_file"
    echo "aws_secret_access_key = $secret_key" >> "$output_file"
    echo "" >> "$output_file"
done
