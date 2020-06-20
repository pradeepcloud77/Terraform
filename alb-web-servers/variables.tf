# Region Credentials
variable "symphony_ip" {}
variable "secret_key" {}
variable "access_key" {}

# Main variables
variable "ami_webserver" {}
variable "web_servers_number" {
  default = 2
}
variable "web_servers_type" {
  default = "t2.small"
}
