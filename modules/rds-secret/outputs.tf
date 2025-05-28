output "rds_db_username" {
  value = jsondecode(aws_secretsmanager_secret_version.rds_credentials.secret_string)["username"]
}

output "rds_db_password" {
  value = jsondecode(aws_secretsmanager_secret_version.rds_credentials.secret_string)["password"]
}

output "rds_parameters" {
  value = aws_secretsmanager_secret.rest_api_rds_db_credentials.name
}