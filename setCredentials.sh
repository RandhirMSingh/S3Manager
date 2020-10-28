#!/bin/sh 

set -e

mkdir -p ~/.aws

touch ~/.aws/credentials

echo "[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials

#aws s3 cp ${FILE} s3://${S3_BUCKET}/ \
 # --region ${AWS_REGION} $*
  
aws s3 cp ${FILE} s3://${S3_BUCKET}/${REPO}/${PR_NUMBER} --recursive --region ${AWS_REGION} $*
ls -all
#this script downloads images from s3 bucket and updates PR
swift /downlaod_S3Object.swift ${S3_BUCKET} ${AWS_REGION} ${REPO} ${PR_NUMBER} ${GITHUB_TOKEN}

rm -rf ~/.aws

