
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target
resource "aws_appautoscaling_target" "ecs_services" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.app_ecs.name}/${aws_ecs_service.app_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy
resource "aws_appautoscaling_policy" "ecs_services_up" {
  name               = "${var.deployment_name}-asc-up"
  service_namespace  = aws_appautoscaling_target.ecs_services.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_services.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_services.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy
resource "aws_appautoscaling_policy" "ecs_services_down" {
  name               = "${var.deployment_name}-asc-down"
  service_namespace  = aws_appautoscaling_target.ecs_services.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_services.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_services.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "ecs_services_cpu_high" {
  alarm_name          = "${var.deployment_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 50
  dimensions = {
    ClusterName = aws_ecs_cluster.app_ecs.name
    ServiceName = aws_ecs_service.app_ecs_service.name
  }
  alarm_actions = [aws_appautoscaling_policy.ecs_services_up.arn]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "ecs_services_cpu_low" {
  alarm_name          = "${var.deployment_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 5
  dimensions = {
    ClusterName = aws_ecs_cluster.app_ecs.name
    ServiceName = aws_ecs_service.app_ecs_service.name
  }
  alarm_actions = [aws_appautoscaling_policy.ecs_services_down.arn]
}