provider "aws" {
  region = "eu-west-1"
}

module "network" {
  source       = "./network"
  project_name = var.project_name
  stage        = var.stage
  vpc_cidr = var.vpc_cidr
  az_count = var.az_count
}

module "endpoints" {
  source       = "./endpoints"
  project_name = var.project_name
  stage        = var.stage
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  vpc_security_group = module.sg.vpc_security_group
  region = var.region
}

module "rds-secret" {
  source       = "./rds-secret"
  project_name = var.project_name
  stage        = var.stage
}

module "sg" {
  source         = "./sg"
  project_name   = var.project_name
  stage          = var.stage
  vpc_id         = module.network.vpc_id
  start_port_rds = var.start_port_rds
  end_port_rds   = var.end_port_rds
  rest_api_port  = var.rest_api_port
}

module "docker-app" {
  source          = "./docker-app"
  repository_name = "api-repo"
  project_name    = var.project_name
  stage           = var.stage
  region          = var.region
}

module "rds-db" {
  source             = "./rds-db"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  rds_security_group = module.sg.rds_security_group
  rds_db_password    = module.rds-secret.rds_db_password
  rds_db_username    = module.rds-secret.rds_db_username
  project_name       = var.project_name
  stage              = var.stage
}

module "ecs" {
  source              = "./ecs"
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  database_subnet_ids = module.network.database_subnet_ids
  image_url           = module.docker-app.image_url
  alb_target_group    = module.alb.alb_target_group
  ecs_security_group  = module.sg.ecs_security_group
  rest_api_port       = var.rest_api_port
  rds_credentials     = module.rds-secret.rds_credentials
  project_name        = var.project_name
  stage               = var.stage
  rds_db_endpoint     = module.rds-db.rds_db_endpoint
  db_name             = module.rds-db.rds_db_name
  region              = var.region
}

module "alb" {
  source             = "./alb"
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  rest_api_port      = var.rest_api_port
  certificate_arn    = module.certificate.acm_certificate_arn
  alb_security_group = module.sg.alb_security_group
  project_name       = var.project_name
  stage              = var.stage
}

module "certificate" {
  source       = "./certificate"
  project_name = var.project_name
  stage        = var.stage
}

