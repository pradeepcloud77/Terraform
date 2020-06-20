## !! Please this example was converted to terraform 0.12 syntax!!

### Terraform WordPress deployment over Kubernetes

## Description:
This TF script will deploy a single region highly available WordPress site with RDS, EC2 and VPC into Stratoscale Symphony. 
The Stratoscale orchestration will done using the AWS provider while the Wordpress will be deployed into Kubernetes using the Kubernetes provider.

## Before running
Ensure that you have both your access and secret keys your Stratoscale's user API credentials

## Important notice while running
Due to a Terraform bug, the Kubernetes provider will only be initialized in a second apply.
Just run 'terraform apply `--auto-approve` when you get the following error after the first `terraform apply`

>* module.k8s_wordpress.kubernetes_secret.mysql-pass: 1 error(s) occurred:
>
>* kubernetes_secret.mysql-pass: Post http://localhost/api/v1/namespaces/default/secrets: dial tcp [::1]:80: connect: connection refused
>* module.k8s_wordpress.kubernetes_persistent_volume_claim.wp_pv_claim: 1 error(s) occurred:
>
>* kubernetes_persistent_volume_claim.wp_pv_claim: Post http://localhost/api/v1/namespaces/default/persistentvolumeclaims: dial tcp [::1]:80: connect: connection refused

## Terraform output
The output will state the public IP of the Load-Balancer and Wordpress Endpoint

    lb_eip = 10.43.180.20
    wordpress_app_endpoint = 10.43.180.20:8080
Goto the Wordpress application endpoint to access Wordpress

### !! Allow a few minutes for the Wordpress to come up !!

### Networks to be provisioned:
- 1 VPC 
- 1 public subnet 
- 1 private subnet 
- 1 Database subnet

### Resources:
- 2-nodes Kubernetes Cluster
  - Wordpress Pod connected to an EBS-based Persistent volume
- 1 ALB
- 1 RDS instance (MySQL 5.7)

### Stratoscale Symphony Requirements:
- Kubernetes engine from the version enabled 
- Load balancer engine enabled 
- Mysql 5.7 RDS engine enabled 
- VPC mode enabled for tenant project

### Tested with: 
+ Terraform v0.11.8
    + provider.aws v2.13.0
    + provider.external v1.1.2
    + provider.kubernetes v1.7.0
    + provider.null v2.1.2

