# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
resource "aws_ecs_cluster" "app_ecs" {
  name = "${var.deployment_name}-ecs"
}

resource "aws_iam_role" "app_fargate_role" {
  name = "${var.deployment_name}-fargate-role"
  assume_role_policy = file("templates/fargate-role.json")
}

resource "aws_iam_role_policy" "app_fargate_role_policy" {
  name = "${var.deployment_name}-fargate-role-policy"
  policy = file("templates/fargate-role-policy.json")
  role = aws_iam_role.app_fargate_role.id
}