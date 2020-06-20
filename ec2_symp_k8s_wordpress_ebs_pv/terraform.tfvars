# Sample tfvars file 
# Stratoscale Symphony credentials

symphony_ip = "<region ip>"
access_key = "<access key>"
secret_key = "<access key>"

symp_domain = "<symp domain>"
symp_user = "<symp user>"
symp_password = "<symp user>"
symp_project = "<symp project>"

k8s_name = "ktest"
k8s_type = "t2.large"
k8s_configfile_path = "<full path to kubeconfig>"
# e.g. "/Users/myuser/.kube/config.tmp"

####
dns_list = ["8.8.8.8", "8.8.4.4"]
wordpress_image = "wordpress:4.8-apache"
wordpress_port = 8080
####

db_user = "<DB admin username>"
db_password = "<DB admin password>"

