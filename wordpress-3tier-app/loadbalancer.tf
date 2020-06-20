#Provision load balancer
resource "aws_alb" "alb" {
  subnets         = [aws_subnet.pub_subnet.id]
  internal        = false
  security_groups = [aws_security_group.lb-sec.id]
}

output "lb_eip" {
  value = aws_alb.alb.dns_name
}

resource "aws_alb_target_group" "targ" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
}

resource "aws_alb_target_group_attachment" "attach_web" {
  target_group_arn = aws_alb_target_group.targ.arn
  target_id        = element(aws_instance.web-server.*.id, count.index)
  port             = 8080
  count            = var.web_number
}

resource "aws_alb_listener" "list" {
  default_action {
    target_group_arn = aws_alb_target_group.targ.arn
    type             = "forward"
  }
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
}

resource "aws_security_group" "lb-sec" {
  name   = "lb-secgroup"
  vpc_id = aws_vpc.app_vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
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

