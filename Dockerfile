FROM python:3.9-alpine

WORKDIR /app

RUN apk --no-cache add \
    groff \
    less \
    && pip install --no-cache-dir boto3 awscli

RUN mkdir /root/.aws
COPY ./credentials /root/.aws/credentials
COPY ./s3_clean_multipart_uploads.py /app

ENV ceph_bucket=""
ENV days=""

ENTRYPOINT ["sh", "-c", "python /app/s3_clean_multipart_uploads.py ${ceph_bucket} ${days}"]
