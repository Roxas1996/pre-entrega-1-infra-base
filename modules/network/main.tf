terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# La red privada
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-vpc" }
}

# Una subred por cada elemento del mapa
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = { Name = "${var.name_prefix}-private-${each.key}" }
}

# Tabla de rutas sin salida a internet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-private-rt" }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Politica del endpoint: solo estos buckets y estas acciones
data "aws_iam_policy_document" "s3_endpoint" {
  statement {
    sid     = "OnlyDataBuckets"
    actions = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"]
    resources = concat(
      [for name in var.allowed_bucket_names : "arn:aws:s3:::${name}"],
      [for name in var.allowed_bucket_names : "arn:aws:s3:::${name}/*"],
    )

    # AWS exige "*" aqui; quien puede acceder lo limitan los roles IAM
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

# Camino interno hacia S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  policy            = data.aws_iam_policy_document.s3_endpoint.json

  tags = { Name = "${var.name_prefix}-s3-endpoint" }
}