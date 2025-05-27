output "alb_security_group" {
  value = aws_security_group.rest_api_alb_sg.id
}

output "ecs_security_group" {
  value = aws_security_group.rest_api_ecs_sg.id
}

output "rds_security_group" {
  value = aws_security_group.rest_api_rds_db_sg.id
}