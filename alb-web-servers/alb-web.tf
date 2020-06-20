###################################
# Creating a VPC & Networking
###################################

resource "aws_vpc" "alb-vpc" {
  cidr_block         = "172.21.0.0/16"
  enable_dns_support = true

  tags = {
    Name = "ALB Example VPC"
  }
}

resource "aws_subnet" "subnet1" {
  cidr_block = "172.21.1.0/24"
  vpc_id     = aws_vpc.alb-vpc.id

  tags = {
    Name = "ALB Example web subnet"
  }
}

# add dhcp options
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

# associate dhcp with vpc
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.alb-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

# create igw
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.alb-vpc.id
}

#new default route table with igw association 
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.alb-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
}

###################################
# Cloud init data
data "template_file" "webconfig" {
  template = file("./webconfig.cfg")
}

data "template_cloudinit_config" "web_config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "webconfig.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.webconfig.rendered
  }
}

###################################

# Creating two instances of web server ami with cloudinit
resource "aws_instance" "web-server" {
  ami           = var.ami_webserver
  instance_type = var.web_servers_type
  subnet_id     = aws_subnet.subnet1.id

  vpc_security_group_ids = [aws_security_group.web-sec.id, aws_security_group.allout.id]
  user_data              = data.template_cloudinit_config.web_config.rendered

  tags = {
    Name = "Web server ${count.index}"
  }

  count = var.web_servers_number
}

##################################
# Security group definitions
# Web server sec group

resource "aws_security_group" "web-sec" {
  name   = "webserver-secgroup"
  vpc_id = aws_vpc.alb-vpc.id

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
}

#public access sg 
# allow all egress traffic (needed for server to download packages)
resource "aws_security_group" "allout" {
  name   = "allout-secgroup"
  vpc_id = aws_vpc.alb-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# LB Sec group definition 
resource "aws_security_group" "lb-sec" {
  name   = "lb-secgroup"
  vpc_id = aws_vpc.alb-vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ping from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##################################

# Creating and attaching the load balancer
# to make LB internal (no floating IP) set internal to true
resource "aws_alb" "alb" {
  name               = "web-alb"
  subnets            = [aws_subnet.subnet1.id]
  internal           = false
  security_groups    = [aws_security_group.lb-sec.id]
  load_balancer_type = "application"
}

resource "aws_alb_target_group" "targ" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.alb-vpc.id
}

resource "aws_alb_target_group_attachment" "attach_web_servers" {
  target_group_arn = aws_alb_target_group.targ.arn
  target_id        = element(aws_instance.web-server.*.id, count.index)
  port             = 8080
  count            = var.web_servers_number
}

resource "aws_alb_listener" "list" {
  default_action {
    target_group_arn = aws_alb_target_group.targ.arn
    type             = "forward"
  }
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
}

