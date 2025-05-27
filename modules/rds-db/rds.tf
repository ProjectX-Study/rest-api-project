resource "random_password" "rest_api_rds_db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "rest_api_rds_db_credentials" {
  name        = "${var.project_name}-${var.stage}-db-mysql-secret"
  description = "Credentials for RDS MySQL"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rest_api_rds_db_credentials.id
  secret_string = jsonencode({
    username = "rds_admin"
    password = random_password.rest_api_rds_db_password.result
  })
}

resource "aws_db_subnet_group" "rest_api_rds_db_subnets" {
  name       = "${var.project_name}-${var.stage}-subnet-group"
  subnet_ids = var.private_subnet_ids  # List of private subnet IDs
  description = "Subnet group for RDS MySQL instance"

  tags = {
    Name = "${var.project_name}-${var.stage}-rds-subnet-group"
  }
}

locals {
  rds_db_credendtials = jsondecode(aws_secretsmanager_secret_version.rds_credentials.secret_string)
}

resource "aws_db_instance" "rest_api_rds_db" {
  identifier             = "${var.project_name}-${var.stage}-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = local.rds_db_credendtials["username"]
  password               = local.rds_db_credendtials["password"]
  db_name                = "${var.project_name}"
  vpc_security_group_ids = [var.rds_security_group]
  db_subnet_group_name   = aws_db_subnet_group.rest_api_rds_db_subnets.name
  skip_final_snapshot    = true
}
