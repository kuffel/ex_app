
# https://registry.terraform.io/providers/hashicorp/template/latest
data "template_file" "app_task_json" {
  template = file("templates/app_task.json")
  vars = {
    docker_tag = var.docker_tag
    deployment_name = var.deployment_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "app_ecs_task" {
  family = "${var.deployment_name}-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  container_definitions = data.template_file.app_task_json.rendered
  execution_role_arn = aws_iam_role.app_fargate_role.arn
  task_role_arn = aws_iam_role.app_fargate_role.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "app_ecs_service" {
  name = "${var.deployment_name}-service"
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