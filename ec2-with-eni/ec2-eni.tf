resource "aws_vpc" "test_vpc" {
  cidr_block = "172.127.0.0/16"
  enable_dns_hostnames = false
  enable_dns_support = false
}

resource "aws_subnet" "test1-network" {
  vpc_id     = "${aws_vpc.test_vpc.id}"
  cidr_block = "172.127.1.0/24"
}

resource "aws_subnet" "test2-network" {
  vpc_id     = "${aws_vpc.test_vpc.id}"
  cidr_block = "172.127.2.0/24"
}

resource "aws_instance" "ec2_instance" {
  ami = "${var.aws_ami}"
  instance_type = "t2.micro"
  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.test1.id}"
  }
  network_interface {
    device_index = 1
    network_interface_id = "${aws_network_interface.test2.id}"
  }
}

resource "aws_network_interface" "test1" {
  subnet_id = "${aws_subnet.test1-network.id}"
}

resource "aws_network_interface" "test2" {
  subnet_id = "${aws_subnet.test2-network.id}"
}
