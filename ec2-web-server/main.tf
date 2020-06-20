resource "aws_instance" "web" {
  instance_type = "t2.medium"

  # Specify our ubuntu ami
  ami = "${var.ubuntu_ami}"

  key_name = "${var.key_name}"

  count=3

  #Assign a pre-created security group
  security_groups = ["${var.sg_web_servers}"]

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  user_data = "${file("userdata.sh")}"
}