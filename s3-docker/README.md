# S3 Backed Docker Registry
This terraform script will create a docker registry based on an ubuntu cloud AMI.   
The docker registry will be automatically configured to keep it's containers in symphony's S3 storage,  
using a bucket created by terraform.

## Required Configuration
1. Get an ubuntu cloud image into Symphony (get one [here](https://cloud-images.ubuntu.com/zesty/current/zesty-server-cloudimg-amd64.img))
2. Create a key pair to be used for the instance created.
3. Fill in the desired bucket name in the `terraform.tfvars` file.

## Running this script
1. Run `terraform apply`
2. Make sure that your docker client is configured to work against    
   non-secure registries, since this registry is http based

## Docker repository usage example
1. `docker pull alpine`
2. `docker tag alpine <registry ip>/alpine`
3. `docker push`


