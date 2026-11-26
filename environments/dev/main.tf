locals {
  name_prefix = "pulso-${var.environment}"
}

module "network" {
  source = "../../modules/network"

  name_prefix     = local.name_prefix
  region          = var.region
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
}

module "identity" {
  source = "../../modules/identity"

  name_prefix        = local.name_prefix
  data_bucket_name   = var.data_bucket_name
  allowed_prefix     = var.allowed_prefix
  audit_bucket_names = [var.state_bucket_name, var.data_bucket_name]
}