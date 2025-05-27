output "cluster_name" {
  value = aws_ecs_cluster.rest_api_ecs.name
}

output "service_name" {
  value = aws_ecs_service.rest_api_service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.rest_api_task.arn
}
