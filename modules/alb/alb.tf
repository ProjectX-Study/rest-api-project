resource "aws_lb" "rest_api_alb" {
  name               = "${var.project_name}-${var.stage}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_security_group]
}

resource "aws_lb_target_group" "rest_api_tg" {
  name     = "${var.project_name}-${var.stage}-target-group"
  port     = var.rest_api_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.rest_api_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rest_api_tg.arn
  }
}
