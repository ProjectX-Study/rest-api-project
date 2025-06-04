data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "rest_api_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-${var.stage}-vpc"
  }
}

resource "aws_subnet" "rest_api_public_subnet" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.rest_api_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.stage}-public-subnets"
  }
}

resource "aws_subnet" "rest_api_private_subnet" {
  count             = var.az_count
  vpc_id            = aws_vpc.rest_api_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project_name}-${var.stage}-private-subnets"
  }
}

resource "aws_subnet" "rest_api_database_subnet" {
  count             = var.az_count
  vpc_id            = aws_vpc.rest_api_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + (var.az_count * 2))
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project_name}-${var.stage}-database-subnets"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.rest_api_vpc.id
  tags = {
    Name = "${var.project_name}-${var.stage}-igw"
  }
}