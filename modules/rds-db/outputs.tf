output "rds_db_endpoint" {
  value = aws_db_instance.rest_api_rds_db.endpoint
}