# AWS API credentials
variable "secret_key" {
}

variable "access_key" {
}

variable "symphony_ip" {
}

# Symphony API credentials
variable "symp_domain" {
}

variable "symp_user" {
}

variable "symp_password" {
}

variable "symp_project" {
  description = "Project Name"
}

# Kubernetes cluster variables
variable "k8s_name" {
  description = "Kubernetres cluster name. Must be unique in this project"
}

variable "k8s_eng" {
  description = "Kubernetes engine version"
  default     = "1.13"
}

variable "k8s_size" {
  description = "Size of data disk of each node"
  default     = "50"
}

variable "k8s_count" {
  description = "Initial cluster node count"
  default     = "2"
}

variable "k8s_type" {
  description = "Instance type of each node"
  default     = "t2.large"
}

variable "k8s_configfile_path" {
  description = "Path to place the Kubernetes config file"
  default     = "~/.kube/config"
}

variable "k8s_private_registry" {
  description = "Address and port of a private registry to be added. Only insecure. e.g. 1.2.3.4:5000"
  default     = ""
}

# Application variables
variable "wordpress_image" {
  description = "The image that will be pulled to pods"
}

variable "wordpress_port" {
  default     = 8080
  description = "The Wordpress service port"
}

variable "dns_list" {
  type        = list(string)
  default     = ["8.8.4.4", "8.8.8.8"]
  description = "DNS list to be attached to the VPC subnets"
}

# Wordpress variables
variable "db_user" {
  description = "Username for the DB"
}

variable "db_password" {
  description = "Password for the DB"
}

