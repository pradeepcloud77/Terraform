# Overview - S3
This terraform will create a Symphony object store S3 bucket, and upload a local file to it.
You will have to fill in the bucket name, key name, and path to object in your local file system.

## Configure
1. Fill in the desired object key name and path to the file you wish to upload.
2. Fill in the desired bucket name in the `terraform.tfvars` file.

## Getting started
1. Make sure you have the latest terraform installed
2. Modify the `terraform.tfvars` file according to your environment
3. Run `terraform apply`
