
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "app_lb" {
  name = "${var.deployment_name}-alb"
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
  name = "${var.deployment_name}-http"
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