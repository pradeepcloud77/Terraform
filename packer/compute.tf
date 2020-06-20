resource "aws_instance" "bastion" {
  ami       = var.bastion_ami_image
  subnet_id = aws_subnet.pub_subnet.id

  tags = {
    Name = "bastion_instance"
  }

  # Can use any aws instance type supported by symphony
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.ingress-ssh.id,
    aws_security_group.egress-all.id,
    aws_security_group.ingress-ping.id,
  ]
  key_name = aws_key_pair.app_keypair.key_name
}

resource "aws_key_pair" "app_keypair" {
  public_key = file(pathexpand(var.public_keypair_path))
  key_name   = "bastion_kp"
}

resource "aws_eip" "bastion-eip" {
  vpc = true
}

resource "aws_eip_association" "myapp_eip_assoc_bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion-eip.id
}

output "bastion_elastic_ips" {
  value = aws_eip.bastion-eip.public_ip
}

####################### General ###################################

resource "aws_security_group" "ingress-ssh" {
  name   = "bastion_ingress-ssh"
  vpc_id = aws_vpc.app_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-ping" {
  name   = "bastion_ingress-ping"
  vpc_id = aws_vpc.app_vpc.id
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress-all" {
  name   = "bastion_egress-all"
  vpc_id = aws_vpc.app_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

