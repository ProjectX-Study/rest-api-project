output "alb_dns_name" {
  value = aws_lb.rest_api_alb.dns_name
}

output "alb_target_group" {
  value = aws_lb_target_group.rest_api_tg.arn
}