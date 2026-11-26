variable "environment" {
  description = "Nombre del entorno"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment debe ser dev, staging o prod."
  }
}

variable "region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Rango de direcciones IP de la VPC"
  type        = string
}

variable "private_subnets" {
  description = "Mapa de zona de disponibilidad a CIDR"
  type        = map(string)
}

variable "state_bucket_name" {
  description = "Bucket donde se guarda el state"
  type        = string
}

variable "data_bucket_name" {
  description = "Bucket de datos al que accede el procesamiento"
  type        = string
}

variable "allowed_prefix" {
  description = "Carpeta permitida dentro del bucket de datos"
  type        = string
}