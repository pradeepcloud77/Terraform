# Overview - Simple EC2 Instance using LVM, expanding its root volume during boot
This terraform example creates a very simple ec2 instance from an ami.  
To get the ami id, simply fetch the image uuid from the Symphony UI, and convert it to the AWS format:
`ami-<uuid without dashes>`

## Getting started
1. Make sure you have the latest terraform installed
2. Modify the `terraform.tfvars` file according to your environment 
3. Run `terraform apply`

## How CloudInit Expands the Root LVM Volume
As the VM boots it will require the cloudconfig.cfg file to be loaded. It will use growpart (needs to be in the image, installed via cloud-utils-growpart) and expand the volume using growpart, pvresize of the second partition, then resizing the logical volume and it's file system with the remaining space from the partition. 

