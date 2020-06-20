## !! Please this example was converted to terraform 0.12 syntax!!

# Simple EC2 Example

This Terraform example creates a very simple EC2 instance from an AMI stored in Symphony.

## Before you begin

Before you can use this Terraform example, you need to:

  * First, do some setup tasks within Symphony.

  * Then, edit the sample `terraform.tfvars` file to specify your environment-specific values for various variables.

  Each task is described below.


### Before you begin: Symphony setup tasks

Before you can use this Terraform example, you need to do the following tasks within the Symphony GUI:

1. Make sure you have used Symphony to:

    * Create a VPC-enabled project

    * Obtain access and secret keys for that project

    For information on how to do these tasks, click [here](../README.md).
    

2. Get the **AMI ID** for the image you want to use for the EC2 instance you are creating:

    **Menu** > **Applications** > **Images**
    
    Click the name of the image you want to use and copy the image's AWS ID value -- it has a format like this:
    
    ami-1b8ecb82893a4d1f9d500ce33d90496c
    
    
### Before you begin: edit `terraform.tfvars`

Use the included `terraform.tfvars` file as a template. For each variable, fill in your environment-specific value, as described below:

| Variable        | Description                                 | Required? |
| --------------- | ------------------------------------------- | --------- |
| symphony_ip     | IP of your Symphony region                  | Yes       |
| access_key      | Access key, for example b5d4e4e9...         | Yes       |
| secret_key      | Secret key, for example fd35f94a...         | Yes       |
| ami_image       | AMI ID, for example ami-123456789999999     | Yes       |
| instance_type   | Type of instance, for example t2.medium     | No        |
| instance_number | How many EC2 instances you want to create   | No        |

## How to use

1. Get the most recent version of Terraform.

2. Run `terraform init`.

3. Run `terraform apply`.
