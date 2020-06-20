## !! Please this example was converted to terraform 0.12 syntax!!

# Overview - Application Load Balancer (ALB/ELBv2)
This terraform will create two webservers from a given ami, and instantiate a load balancer to actively balance them.
To get the ami id, simply fetch the image uuid from the Symphony UI, and convert it to the AWS format:
`ami-<uuid without dashes>`

>This example's load balancer is configured as external, you can modify it to internal by modifying the alb-web.tf file

## Symphony Pre-requisite Check list
1. Ensure you have enabled and initialized load balancer service
2. Ensure you have imported an Ubuntu Xenial cloud image and made this image public, grab the AMI ID and insert it into your .tfvars file
3. Ensure your tenants project that you are deploying into has VPC mode enabled, with access keys generated (insert the access/secret keys into your .tfvars file)

## Getting started
1. Make sure you have the latest terraform installed
2. Create/Specify a security group
3. Modify the `terraform.tfvars` file according to your environment
4. Run `terraform apply`
5. After the solution is deployed, you should be able to go to the IP of your load balancer and refresh, each time it should redirect you to the other web server which is displaying it's instance ID so you know you're on a different server. 
