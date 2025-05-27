output "vpc_id" {
  value = aws_vpc.rest_api_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.rest_api_public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.rest_api_private_subnet[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.rest_api_database_subnet[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}
