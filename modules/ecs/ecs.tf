resource "aws_ecs_cluster" "rest_api_ecs" {
  name = "${var.project_name}-${var.stage}-ecs-cluster"
}

resource "aws_ecs_task_definition" "rest_api_task" {
  family                   = "${var.project_name}-${var.stage}-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "${var.project_name}-${var.stage}-container"
    image = var.image_url
    portMappings = [{
      containerPort = var.rest_api_port
      protocol      = "tcp"
    }]
    environment = [
      { name = "DB_HOST", value = var.rds_db_endpoint }
    ]
  }])
}

resource "aws_ecs_service" "rest_api_service" {
  name            = "${var.project_name}-${var.stage}-service"
  cluster         = aws_ecs_cluster.rest_api_ecs.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.rest_api_task.arn

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [var.ecs_security_group]
  }

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "${var.project_name}-${var.stage}-container"
    container_port   = var.rest_api_port
  }
}
