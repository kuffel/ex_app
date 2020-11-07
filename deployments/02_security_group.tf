
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "app_sg" {
  name = "${var.deployment_name}-sg"
  description = "Security rules for ${var.deployment_name}"
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