# Create db instance 

#make db subnet group 
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "wordpress_db_subnet"
  subnet_ids = [aws_subnet.db_subnet.id]
}

#provision the database
resource "aws_db_instance" "wpdb" {
  identifier             = "wpdb"
  instance_class         = "db.m1.large"
  allocated_storage      = 20
  engine                 = "mysql"
  name                   = "wordpress_db"
  password               = var.db_password
  username               = var.db_user
  engine_version         = "5.7.00"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  vpc_security_group_ids = [aws_security_group.db.id]

  # Workaround for Symphony 
  lifecycle {
    ignore_changes = [
      auto_minor_version_upgrade,
      vpc_security_group_ids,
    ]
  }
}

resource "aws_security_group" "db" {
  name   = "db-secgroup"
  vpc_id = aws_vpc.app_vpc.id

  # ssh access from anywhere
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

