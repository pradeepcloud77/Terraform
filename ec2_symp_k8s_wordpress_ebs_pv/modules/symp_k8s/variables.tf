variable "symp_host" {
}

variable "symp_domain" {
}

variable "symp_user" {
}

variable "symp_password" {
  description = "Symphony password. Wrap it in single and double quotes. e.g. \"'#edcvfr4'\" "
}

variable "symp_project" {
  description = "Project ID"
}

variable "k8s_name" {
  description = "Kubernetres cluster name. Must be unique in this project"
}

variable "k8s_subnet" {
}

variable "k8s_eip" {
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
  default = "~/.kube/config"
}

variable "k8s_private_registry" {
  description = "Address and port of a private registry to be added. Only insecure. e.g. 1.2.3.4:5000"
  default     = ""
}

