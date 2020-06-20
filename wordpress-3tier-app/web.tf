#Deploy Wordpress instances

#Reference to bash script which prepares xenial image
data "template_file" "wpdeploy" {
  template = file("./webconfig.cfg")

  vars = {
    db_ip       = aws_db_instance.wpdb.address
    db_user     = var.db_user
    db_password = var.db_password
  }
}

data "template_cloudinit_config" "wpdeploy_config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "webconfig.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.wpdeploy.rendered
  }
}

resource "aws_key_pair" "app_keypair" {
  public_key = file(var.public_keypair_path)
  key_name   = "wp_app_kp"
}

resource "aws_instance" "web-server" {
  ami = var.web_ami

  # The public SG is added for SSH and ICMP
  vpc_security_group_ids = [aws_security_group.web-sec.id, aws_security_group.allout.id]
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.web_subnet.id
  key_name               = aws_key_pair.app_keypair.key_name

  tags = {
    Name = "web-server-${count.index}"
  }
  count      = var.web_number
  depends_on = [aws_db_instance.wpdb]
  user_data  = data.template_cloudinit_config.wpdeploy_config.rendered
}

# bastion server
resource "aws_instance" "bastion" {
  ami = var.web_ami

  # The public SG is added for SSH and ICMP
  vpc_security_group_ids = [aws_security_group.pub.id, aws_security_group.allout.id]
  instance_type          = var.web_instance_type
  key_name               = aws_key_pair.app_keypair.key_name
  subnet_id              = aws_subnet.pub_subnet.id

  tags = {
    Name = "WordPress Bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  depends_on = [aws_internet_gateway.app_igw]
}

resource "aws_eip_association" "myapp_eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}

output "Bastion_Elastic_IP" {
  value = aws_eip.bastion_eip.public_ip
}

output "web-server_private_ips" {
  value = zipmap(
    aws_instance.web-server.*.id,
    aws_instance.web-server.*.private_ip,
  )
}

resource "aws_security_group" "web-sec" {
  name   = "webserver-secgroup"
  vpc_id = aws_vpc.app_vpc.id

  # Internal HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ssh from anywhere (for debugging)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#public access sg 
resource "aws_security_group" "pub" {
  name   = "pub-secgroup"
  vpc_id = aws_vpc.app_vpc.id

  # ssh access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allout" {
  name   = "allout-secgroup"
  vpc_id = aws_vpc.app_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

