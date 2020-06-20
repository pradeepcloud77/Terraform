#!/bin/bash -v

ACCESS_KEY=${access_key}
SECRET_KEY=${secret_key}
REGION=${region}
BUCKET_NAME=${bucket_name}

###### updated OS and dependencies ######

apt-get update -y
apt-get remove -y docker docker-engine docker.io
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce

###### configure docker registry #########

cat << EOF >> /home/ubuntu/s3conf.yml
version: 0.1
log:
  level: debug
  formatter: text
  fields:
    service: registry
    environment: staging
storage:
  s3:
    accesskey: $ACCESS_KEY
    secretkey: $SECRET_KEY
    region: symphony
    regionendpoint: http://10.16.128.10:1060
    bucket: $BUCKET_NAME
    encrypt: false
    secure: false
    v4auth: true
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
EOF


docker run -dt -p 5000:5000 -v /home/ubuntu/s3conf.yml:/etc/docker/registry/config.yml registry:2
