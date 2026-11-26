output "vpc_id" {
  description = "ID de la VPC"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value       = module.network.private_subnet_ids
}

output "private_route_table_id" {
  description = "ID de la tabla de rutas privada"
  value       = module.network.private_route_table_id
}

output "s3_endpoint_id" {
  description = "ID del S3 Gateway Endpoint"
  value       = module.network.s3_endpoint_id
}

output "processing_role_arn" {
  description = "ARN del rol de procesamiento"
  value       = module.identity.processing_role_arn
}

output "audit_role_arn" {
  description = "ARN del rol de auditoria"
  value       = module.identity.audit_role_arn
}