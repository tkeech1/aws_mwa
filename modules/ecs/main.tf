resource "aws_ecs_cluster" "mwa_cluster" {
  name = "mwa_cluster"
  tags = {
    environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "mwa_log_group" {
  name              = "mwa_log_group"
  retention_in_days = 1

  tags = {
    environment = var.environment
  }
}

/*resource "aws_cloudwatch_log_stream" "mwa_log_stream" {
  name           = "mwa_log_stream"
  log_group_name = aws_cloudwatch_log_group.mwa_log_group.name
}*/

resource "aws_ecs_task_definition" "mwa_ecs_task_definition" {
  family                   = "mwa_ecs_task_definition"
  execution_role_arn       = var.ecs_role_arn
  task_role_arn            = var.ecs_task_role_arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"

  container_definitions = templatefile("./modules/ecs/task-definition.json", { ecr_image_tag = var.ecr_image_tag, mwa_log_group = aws_cloudwatch_log_group.mwa_log_group.name })

  tags = {
    environment = var.environment
  }
}

resource "aws_ecs_service" "mwa_http_service" {
  name                               = "mwa_http_service"
  cluster                            = aws_ecs_cluster.mwa_cluster.id
  task_definition                    = aws_ecs_task_definition.mwa_ecs_task_definition.arn
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  desired_count                      = 1

  network_configuration {
    subnets          = [var.private_subnet_one_id, var.private_subnet_two_id]
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "MWA-Service"
    container_port   = 8080
  }

  #placement_constraints {
  #  type       = "memberOf"
  #  expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #}
}
