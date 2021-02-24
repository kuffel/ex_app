
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "app_dns_record" {
  zone_id = "Z3VH23M26EBR3N"
  name = var.deployment_name
  type = "A"
  alias {
    evaluate_target_health = true
    name = aws_lb.app_lb.dns_name
    zone_id = aws_lb.app_lb.zone_id
  }
}

resource "aws_route53_record" "app_dns_record_ipv6" {
  zone_id = "Z3VH23M26EBR3N"
  name = var.deployment_name
  type = "AAAA"
  alias {
    evaluate_target_health = true
    name = aws_lb.app_lb.dns_name
    zone_id = aws_lb.app_lb.zone_id
  }
}