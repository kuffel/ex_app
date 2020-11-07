
output "app_load_balancer_fqdn" {
  value = aws_lb.app_lb.dns_name
}

output "installation_fqdn" {
  value = aws_route53_record.app_dns_record.fqdn
}