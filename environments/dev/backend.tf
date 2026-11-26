terraform {
  backend "s3" {
    bucket         = "tf-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-lock-dev"
  }
}