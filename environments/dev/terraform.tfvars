environment = "dev"
region      = "us-east-1"
vpc_cidr    = "10.20.0.0/16"

private_subnets = {
  "us-east-1a" = "10.20.1.0/24"
  "us-east-1b" = "10.20.2.0/24"
}

state_bucket_name = "tf-state-dev"
data_bucket_name  = "pulso-lakehouse-dev"
allowed_prefix    = "streaming/"