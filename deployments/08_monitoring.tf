
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "${var.deployment_name}-logs"
  retention_in_days = 30
}