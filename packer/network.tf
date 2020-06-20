resource "aws_vpc" "app_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "Bastion VPC"
  }
}

resource "aws_subnet" "pub_subnet" {
  cidr_block = "192.168.10.0/24"
  vpc_id     = aws_vpc.app_vpc.id
  tags = {
    Name = "Bastion Subnet"
  }
  depends_on = [aws_vpc_dhcp_options_association.dns_resolver]
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_default_route_table" "default_route" {
  default_route_table_id = aws_vpc.app_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.app_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

