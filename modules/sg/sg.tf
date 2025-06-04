resource "aws_security_group" "rest_api_alb_sg" {
  name        = "${var.project_name}-${var.stage}-alb-sg"
  description = "Allow HTTPS from public"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from the world"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.stage}-alb-sg"
  }
}

resource "aws_security_group" "rest_api_ecs_sg" {
  name        = "${var.project_name}-${var.stage}-ecs-sg"
  description = "Allow DB access from application"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL access from app SG"
    from_port       = var.rest_api_port
    to_port         = var.rest_api_port
    protocol        = "tcp"
    security_groups = [aws_security_group.rest_api_alb_sg.id] # reference to app SG
  }

  egress {
    from_port       = var.start_port_rds
    to_port         = var.end_port_rds
    protocol        = "tcp"
    security_groups = [aws_security_group.rest_api_rds_db_sg.id]
  }

  tags = {
    Name = "${var.project_name}-${var.stage}-ecs-sg"
  }
}

resource "aws_security_group" "rest_api_rds_db_sg" {
  name        = "${var.project_name}-${var.stage}-rds-db-sg"
  description = "Allow DB access from application"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL access from app SG"
    from_port       = var.start_port_rds
    to_port         = var.end_port_rds
    protocol        = "tcp"
    security_groups = [aws_security_group.rest_api_alb_sg.id] # reference to app SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.stage}-rds-db-sg"
  }
}

resource "aws_security_group" "rest_api_vpc_endpoint_sg" {
  name        = "${var.project_name}-${var.stage}vpc-endpoint-sg"
  description =  "Allows ECS tasks to talk to AWS APIs via interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.rest_api_ecs_sg.id] # allow ECS tasks to connect
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
