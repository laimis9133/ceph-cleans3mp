# ceph-cleans3mp
Cleanup incomplete multipart uploads for Ceph S3 buckets on your cluster using Python boto3.  
AWS S3 has a option to perform this via UI however Ceph does not. Maybe someone will find it useful.

## Usage
For a single bucket cleanup simply run the python script  
`python3 s3_clean_multipart_uploads.py {ceph_bucket} {days}`  
Where {days} is your retention period. It will cleanup all incomplete multipart uploads older than this number.  

For a regular cluster wide cleanup you can setup Kubernetes cronjobs for each bucket.  
Run the `get-bucket-keys.sh` on your Ceph node that has radosgw-admin available. It will generate a bucket list as well as a awscli credentials file.  
Place the credentials file with the python script next to the Dockerfile and generate a container image.  
Setup Kubernetes secrets for container registry access and add them to the `cron_template`.  
Keep the bucketlist file in your repository (like GitLab) - the CI process will monitor its contents and apply changes to a Kubernetes cronjob. Every bucket gets its own cron.
The CI randomizes minutes for the cron schedule in order to not shoot all cleanups at the same time in case you have a lot of buckets.
You can modify the default cleanup policy in the `cron_template` - currently its set to 10 days.

### Important
There is a known [bug](https://tracker.ceph.com/issues/61510) with some Ceph versions with the multipart upload timestamp. Upgrade your Ceph to avoid!
