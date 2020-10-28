
provider "aws" {
  version = "~> 2.70"
  region = "eu-central-1"
  profile = "kuffel"
}

terraform {
  backend "s3" {
    key    = "ex_app.tfstate"
    region = "eu-central-1"
    bucket = "kuffel-terraform-states"
    profile = "kuffel"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "ex-app-logs"
  retention_in_days = 30
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = "172.16.1.0/24"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "ex-app-vpc"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "app_ig" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "ex-app-ig"
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
    Name = "ex-app-rt"
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
    Name = "ex-app-subnet-a"
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
    Name = "ex-app-subnet-b"
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
    Name = "ex-app-subnet-c"
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "app_sg" {
  name = "ex-app-sg"
  description = "Rules for ex_app"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "HTTP"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "HTTPS"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    description = "VPC internal traffic"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "ex-app-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
resource "aws_ecs_cluster" "app_ecs" {
  name = "ex-app-ecs"
}

resource "aws_iam_role" "app_fargate_role" {
  name = "ex-app-fargate-role"
  assume_role_policy = file("aws/fargate-role.json")
}

resource "aws_iam_role_policy" "app_fargate_role_policy" {
  name = "ex-app-fargate-role-policy"
  policy = file("aws/fargate-role-policy.json")
  role = aws_iam_role.app_fargate_role.id
}

# https://registry.terraform.io/providers/hashicorp/template/latest
data "template_file" "app_task_json" {
  template = file("aws/app_task.json")
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "app_ecs_task" {
  family = "app-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 512
  memory = 1024
  container_definitions = data.template_file.app_task_json.rendered
  execution_role_arn = aws_iam_role.app_fargate_role.arn
  task_role_arn = aws_iam_role.app_fargate_role.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "app_ecs_service" {
  name = "app-service"
  cluster = aws_ecs_cluster.app_ecs.id
  task_definition = aws_ecs_task_definition.app_ecs_task.arn
  desired_count = "1"
  deployment_minimum_healthy_percent = 50
  launch_type = "FARGATE"
  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.app_sg.id]
    subnets = [
      aws_subnet.app_subnet_a.id,
      aws_subnet.app_subnet_b.id,
      aws_subnet.app_subnet_c.id
    ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group_app_http.arn
    container_name = "app"
    container_port = 4000
  }
  depends_on = [
    aws_lb.app_lb
  ]
  propagate_tags = "SERVICE"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "app_lb" {
  name = "ex-app-alb"
  enable_cross_zone_load_balancing = true
  load_balancer_type = "application"
  ip_address_type = "dualstack"
  idle_timeout = 900
  subnets = [
    aws_subnet.app_subnet_a.id,
    aws_subnet.app_subnet_b.id,
    aws_subnet.app_subnet_c.id
  ]
  security_groups = [
    aws_security_group.app_sg.id
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "lb_target_group_app_http" {
  name = "ex-app-http"
  port = 4000
  protocol = "HTTP"
  vpc_id = aws_vpc.app_vpc.id
  target_type = "ip"
  health_check {
    path = "/"
    protocol = "HTTP"
    port = "4000"
    matcher = "200-499"
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    interval = 10
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_alb_listener" "lb_listener_app" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "lb_listener_app_https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:eu-central-1:418124467834:certificate/c9545394-4617-4ed0-b8fc-241b75df3c7d"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group_app_http.arn
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "app_dns_record" {
  zone_id = "Z3VH23M26EBR3N"
  name = "ex-app"
  type = "A"
  alias {
    evaluate_target_health = true
    name = aws_lb.app_lb.dns_name
    zone_id = aws_lb.app_lb.zone_id
  }
}




output "app_load_balancer_fqdn" {
  value = aws_lb.app_lb.dns_name
}

output "installation_fqdn" {
  value = aws_route53_record.app_dns_record.fqdn
}



