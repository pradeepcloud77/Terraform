provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"

  endpoints {
     ec2 = "https://${var.symphony_ip}/api/v2/aws/ec2"
  }

  insecure = "true"
  skip_metadata_api_check = true
  skip_credentials_validation = true
  skip_requesting_account_id = true

  # Pinning AWS plugin version
  version = "=1.31.0"

  # No importance for this value currently
  region = "us-east-1"
}
