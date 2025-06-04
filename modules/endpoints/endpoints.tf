resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
  security_group_ids = [var.vpc_security_group]

  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.stage}-docker-api-endpoint-private"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
  security_group_ids = [var.vpc_security_group]

  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.stage}-docker-repository-endpoint-private"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
  security_group_ids = [var.vpc_security_group]

  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.stage}-secret-endpoint-private"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
  security_group_ids = [var.vpc_security_group]

  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.stage}-logs-endpoint-private"
  }
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.vpc_security_group]

  private_dns_enabled = true
  tags = {
    Name = "${var.project_name}-${var.stage}-sts-endpoint-private"
  }
}
