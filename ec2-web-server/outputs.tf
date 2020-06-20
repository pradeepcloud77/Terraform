output "localaddress" {
  value = ["${aws_instance.web.*.private_ip}"]
}

output "publicaddress" {
  value = ["${aws_instance.web.*.public_ip}"]
}