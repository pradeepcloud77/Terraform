# RDS Simple Example
This example demonstrates creating an RDS instance using terraform, it will create an instance  
and assign it with a custom parameters group with modified parameters.

> Note: This example will provision a MySQL 5.7 version

## Getting started
1. Make sure you have the database engine you want to provision is enabled in Symphony.
2. Make sure you have the latest terraform installed
3. Modify the `terraform.tfvars` file according to your environment variables
4. Run `terraform apply`