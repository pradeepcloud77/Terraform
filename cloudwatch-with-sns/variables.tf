variable "secret_key" {}
variable "access_key" {}
variable "symphony_ip" {}
variable "aws_ami" {}

variable "instance_count" {
  default = 1
}
variable "instance_type" {
  default = "t2.micro"
}
variable "cloudwatch_alarm_prefix" {
  default = "cloudwatch_alarm_"
}

variable "sns_topic_name_prefix" {
  description = "The prefix of the SNS Topic name to send events to"
  default     = "tf-example-sns-topic"
}
