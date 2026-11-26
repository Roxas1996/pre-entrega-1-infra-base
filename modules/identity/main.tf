terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id      = data.aws_caller_identity.current.account_id
  data_bucket_arn = "arn:aws:s3:::${var.data_bucket_name}"
}

# ---------- Rol de procesamiento ----------
data "aws_iam_policy_document" "processing_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "kinesisanalytics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "processing" {
  name               = "${var.name_prefix}-processing-role"
  assume_role_policy = data.aws_iam_policy_document.processing_trust.json
}

data "aws_iam_policy_document" "processing_s3" {
  statement {
    sid       = "ListOnlyPrefix"
    actions   = ["s3:ListBucket"]
    resources = [local.data_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.allowed_prefix}*"]
    }
  }

  statement {
    sid       = "ReadWriteOnlyPrefix"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${local.data_bucket_arn}/${var.allowed_prefix}*"]
  }
}

resource "aws_iam_role_policy" "processing_s3" {
  name   = "${var.name_prefix}-processing-s3"
  role   = aws_iam_role.processing.id
  policy = data.aws_iam_policy_document.processing_s3.json
}

# ---------- Rol de auditoria (solo lectura) ----------
data "aws_iam_policy_document" "audit_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "audit" {
  name               = "${var.name_prefix}-audit-role"
  assume_role_policy = data.aws_iam_policy_document.audit_trust.json
}

data "aws_iam_policy_document" "audit_read" {
  # AWS no permite limitar las acciones Describe de EC2 a un recurso concreto
  statement {
    sid = "ReadNetwork"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables",
      "ec2:DescribeVpcEndpoints",
    ]
    resources = ["*"]
  }

  statement {
    sid = "ReadProjectRoles"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/${var.name_prefix}-*"]
  }

  statement {
    sid = "ReadBucketConfig"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration",
    ]
    resources = [for name in var.audit_bucket_names : "arn:aws:s3:::${name}"]
  }
}

resource "aws_iam_role_policy" "audit_read" {
  name   = "${var.name_prefix}-audit-read"
  role   = aws_iam_role.audit.id
  policy = data.aws_iam_policy_document.audit_read.json
}