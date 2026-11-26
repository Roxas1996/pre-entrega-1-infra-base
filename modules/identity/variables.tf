variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "data_bucket_name" {
  description = "Nombre del bucket donde trabajara el procesamiento"
  type        = string
}

variable "allowed_prefix" {
  description = "Carpeta del bucket a la que se limita el acceso, terminada en /"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_-]+/$", var.allowed_prefix))
    error_message = "allowed_prefix debe terminar en / y no empezar con /."
  }
}

variable "audit_bucket_names" {
  description = "Buckets cuya configuracion puede revisar el rol de auditoria"
  type        = list(string)
}