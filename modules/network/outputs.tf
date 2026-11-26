output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value       = [for s in aws_subnet.private : s.id]
}

output "private_route_table_id" {
  description = "ID de la tabla de rutas privada"
  value       = aws_route_table.private.id
}

output "s3_endpoint_id" {
  description = "ID del Gateway Endpoint de S3"
  value       = aws_vpc_endpoint.s3.id
}