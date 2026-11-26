variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos, por ejemplo pulso-dev"
  type        = string
}

variable "region" {
  description = "Region de AWS"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango de direcciones IP de la VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr debe ser un CIDR valido, por ejemplo 10.20.0.0/16."
  }
}

variable "private_subnets" {
  description = "Mapa de zona de disponibilidad a CIDR de cada subred privada"
  type        = map(string)

  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "Se necesitan al menos 2 subredes en zonas distintas."
  }
}
variable "allowed_bucket_names" {
  description = "Buckets a los que se puede llegar a traves del S3 Endpoint"
  type        = list(string)
}