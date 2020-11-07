
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = "172.16.1.0/24"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.deployment_name}-vpc"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "app_ig" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "${var.deployment_name}-ig"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_ig.id
  }
  tags = {
    Name = "${var.deployment_name}-rt"
  }
}

# Subnets and route tables
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association

resource "aws_subnet" "app_subnet_a" {
  vpc_id = aws_vpc.app_vpc.id
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  cidr_block = cidrsubnet(aws_vpc.app_vpc.cidr_block, 2, 0)
  ipv6_cidr_block = cidrsubnet(aws_vpc.app_vpc.ipv6_cidr_block, 8, 1)
  availability_zone = "eu-central-1a"
  tags = {
    Name = "${var.deployment_name}-subnet-a"
  }
}

resource "aws_subnet" "app_subnet_b" {
  vpc_id = aws_vpc.app_vpc.id
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  cidr_block = cidrsubnet(aws_vpc.app_vpc.cidr_block, 2, 1)
  ipv6_cidr_block = cidrsubnet(aws_vpc.app_vpc.ipv6_cidr_block, 8, 2)
  availability_zone = "eu-central-1b"
  tags = {
    Name = "${var.deployment_name}-subnet-b"
  }
}

resource "aws_subnet" "app_subnet_c" {
  vpc_id = aws_vpc.app_vpc.id
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  cidr_block = cidrsubnet(aws_vpc.app_vpc.cidr_block, 2, 2)
  ipv6_cidr_block = cidrsubnet(aws_vpc.app_vpc.ipv6_cidr_block, 8, 3)
  availability_zone = "eu-central-1c"
  tags = {
    Name = "${var.deployment_name}-subnet-c"
  }
}

resource "aws_route_table_association" "platform_route_table_subnet_a" {
  subnet_id = aws_subnet.app_subnet_a.id
  route_table_id = aws_route_table.app_route_table.id
}

resource "aws_route_table_association" "platform_route_table_subnet_b" {
  subnet_id = aws_subnet.app_subnet_b.id
  route_table_id = aws_route_table.app_route_table.id
}

resource "aws_route_table_association" "platform_route_table_subnet_c" {
  subnet_id = aws_subnet.app_subnet_c.id
  route_table_id = aws_route_table.app_route_table.id
}