data "aws_db_instance" "rds_db" {
  db_instance_identifier = "${var.project_name}-${var.stage}-db"
}

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
  secret_id = aws_secretsmanager_secret.rest_api_rds_db_credentials.id
  secret_string = jsonencode({
    username = "rds_admin"
    password = random_password.rest_api_rds_db_password.result
    endpoint = data.aws_db_instance.rds_db.endpoint
    db_name  = data.aws_db_instance.rds_db.db_name
  })
}