data "aws_iam_policy_document" "rest_api_ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "rest_api_ecs_task_execution" {
  name               = "${var.project_name}-${var.stage}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.rest_api_ecs_task_assume_role.json
}

resource "aws_iam_policy_attachment" "secrets_access" {
  name       = "${var.project_name}-${var.stage}-ecs-secrets-access"
  roles      = [aws_iam_role.rest_api_ecs_task_execution.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


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
      {
        name  = "SECRET_NAME",
        value = var.rds_credentials
      },
      {
        name  = "AWS_REGION",
        value = var.region
      },
      {
        name  = "db_name",
        value = var.db_name
      },
      {
        name  = "db_endpoint",
        value = var.rds_db_endpoint
      }
    ]
  }])
}

resource "aws_ecs_service" "rest_api_service" {
  name             = "${var.project_name}-${var.stage}-service"
  cluster          = aws_ecs_cluster.rest_api_ecs.id
  launch_type      = "FARGATE"
  desired_count    = 2
  task_definition  = aws_ecs_task_definition.rest_api_task.arn
  platform_version = "LATEST"

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

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  # Force a new deployment if the task_definition changes
  force_new_deployment = true

  depends_on = [
    aws_ecs_task_definition.rest_api_task
  ]
}
