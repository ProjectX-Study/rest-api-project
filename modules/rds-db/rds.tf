resource "aws_db_subnet_group" "rest_api_rds_db_subnets" {
  name        = "${var.project_name}-${var.stage}-subnet-group"
  subnet_ids  = var.private_subnet_ids # List of private subnet IDs
  description = "Subnet group for RDS MySQL instance"

  tags = {
    Name = "${var.project_name}-${var.stage}-rds-subnet-group"
  }
}

resource "aws_db_instance" "rest_api_rds_db" {
  identifier             = "${var.project_name}-${var.stage}-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.rds_db_username
  password               = var.rds_db_password
  db_name                = var.project_name
  vpc_security_group_ids = [var.rds_security_group]
  db_subnet_group_name   = aws_db_subnet_group.rest_api_rds_db_subnets.name
  skip_final_snapshot    = true
}
