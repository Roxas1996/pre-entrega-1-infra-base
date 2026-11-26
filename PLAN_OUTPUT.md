# Evidencia del despliegue en LocalStack

## tflocal plan

```text

Warning: Deprecated Parameter

The parameter "dynamodb_table" is deprecated. Use parameter "use_lockfile"
instead.
module.network.data.aws_iam_policy_document.s3_endpoint: Reading...
module.identity.data.aws_caller_identity.current: Reading...
module.identity.data.aws_iam_policy_document.processing_trust: Reading...
module.identity.data.aws_iam_policy_document.processing_s3: Reading...
module.identity.data.aws_iam_policy_document.processing_s3: Read complete after 0s [id=2873686354]
module.identity.data.aws_iam_policy_document.processing_trust: Read complete after 0s [id=1237821689]
module.network.data.aws_iam_policy_document.s3_endpoint: Read complete after 0s [id=1629151202]
module.identity.data.aws_caller_identity.current: Read complete after 0s [id=000000000000]
module.identity.data.aws_iam_policy_document.audit_trust: Reading...
module.identity.data.aws_iam_policy_document.audit_read: Reading...
module.identity.data.aws_iam_policy_document.audit_trust: Read complete after 0s [id=2705921516]
module.identity.data.aws_iam_policy_document.audit_read: Read complete after 0s [id=2832629124]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.identity.aws_iam_role.audit will be created
  + resource "aws_iam_role" "audit" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::000000000000:root"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "pulso-dev-audit-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Project"     = "pulso-plataforma-datos"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.identity.aws_iam_role.processing will be created
  + resource "aws_iam_role" "processing" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = [
                              + "lambda.amazonaws.com",
                              + "kinesisanalytics.amazonaws.com",
                            ]
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "pulso-dev-processing-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Project"     = "pulso-plataforma-datos"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.identity.aws_iam_role_policy.audit_read will be created
  + resource "aws_iam_role_policy" "audit_read" {
      + id          = (known after apply)
      + name        = "pulso-dev-audit-read"
      + name_prefix = (known after apply)
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:DescribeVpcs",
                          + "ec2:DescribeVpcEndpoints",
                          + "ec2:DescribeSubnets",
                          + "ec2:DescribeRouteTables",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "ReadNetwork"
                    },
                  + {
                      + Action   = [
                          + "iam:ListRolePolicies",
                          + "iam:ListAttachedRolePolicies",
                          + "iam:GetRolePolicy",
                          + "iam:GetRole",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:iam::000000000000:role/pulso-dev-*"
                      + Sid      = "ReadProjectRoles"
                    },
                  + {
                      + Action   = [
                          + "s3:GetEncryptionConfiguration",
                          + "s3:GetBucketVersioning",
                          + "s3:GetBucketPublicAccessBlock",
                          + "s3:GetBucketPolicy",
                          + "s3:GetBucketLocation",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:s3:::tf-state-dev",
                          + "arn:aws:s3:::pulso-lakehouse-dev",
                        ]
                      + Sid      = "ReadBucketConfig"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + role        = (known after apply)
    }

  # module.identity.aws_iam_role_policy.processing_s3 will be created
  + resource "aws_iam_role_policy" "processing_s3" {
      + id          = (known after apply)
      + name        = "pulso-dev-processing-s3"
      + name_prefix = (known after apply)
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:ListBucket"
                      + Condition = {
                          + StringLike = {
                              + "s3:prefix" = "streaming/*"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:s3:::pulso-lakehouse-dev"
                      + Sid       = "ListOnlyPrefix"
                    },
                  + {
                      + Action   = [
                          + "s3:PutObject",
                          + "s3:GetObject",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::pulso-lakehouse-dev/streaming/*"
                      + Sid      = "ReadWriteOnlyPrefix"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + role        = (known after apply)
    }

  # module.network.aws_route_table.private will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = (known after apply)
      + tags             = {
          + "Name" = "pulso-dev-private-rt"
        }
      + tags_all         = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "pulso-dev-private-rt"
          + "Project"     = "pulso-plataforma-datos"
        }
      + vpc_id           = (known after apply)
    }

  # module.network.aws_route_table_association.private["us-east-1a"] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.aws_route_table_association.private["us-east-1b"] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.aws_subnet.private["us-east-1a"] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.20.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + network_firewall_connectivity_type             = (known after apply)
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Name" = "pulso-dev-private-us-east-1a"
        }
      + tags_all                                       = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "pulso-dev-private-us-east-1a"
          + "Project"     = "pulso-plataforma-datos"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_subnet.private["us-east-1b"] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.20.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + network_firewall_connectivity_type             = (known after apply)
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Name" = "pulso-dev-private-us-east-1b"
        }
      + tags_all                                       = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "pulso-dev-private-us-east-1b"
          + "Project"     = "pulso-plataforma-datos"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_vpc.this will be created
  + resource "aws_vpc" "this" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.20.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + network_firewall_association         = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "us-east-1"
      + tags                                 = {
          + "Name" = "pulso-dev-vpc"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "pulso-dev-vpc"
          + "Project"     = "pulso-plataforma-datos"
        }
    }

  # module.network.aws_vpc_endpoint.s3 will be created
  + resource "aws_vpc_endpoint" "s3" {
      + arn                   = (known after apply)
      + cidr_blocks           = (known after apply)
      + dns_entry             = (known after apply)
      + id                    = (known after apply)
      + ip_address_type       = (known after apply)
      + network_interface_ids = (known after apply)
      + owner_id              = (known after apply)
      + policy                = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = [
                          + "s3:PutObject",
                          + "s3:ListBucket",
                          + "s3:GetObject",
                        ]
                      + Effect    = "Allow"
                      + Principal = "*"
                      + Resource  = [
                          + "arn:aws:s3:::pulso-lakehouse-dev/*",
                          + "arn:aws:s3:::pulso-lakehouse-dev",
                        ]
                      + Sid       = "OnlyDataBuckets"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + prefix_list_id        = (known after apply)
      + private_dns_enabled   = (known after apply)
      + region                = "us-east-1"
      + requester_managed     = (known after apply)
      + route_table_ids       = (known after apply)
      + security_group_ids    = (known after apply)
      + service_name          = "com.amazonaws.us-east-1.s3"
      + service_region        = (known after apply)
      + state                 = (known after apply)
      + subnet_ids            = (known after apply)
      + tags                  = {
          + "Name" = "pulso-dev-s3-endpoint"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "pulso-dev-s3-endpoint"
          + "Project"     = "pulso-plataforma-datos"
        }
      + vpc_endpoint_type     = "Gateway"
      + vpc_id                = (known after apply)

      + dns_options (known after apply)

      + subnet_configuration (known after apply)
    }

Plan: 11 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + audit_role_arn         = (known after apply)
  + private_route_table_id = (known after apply)
  + private_subnet_ids     = [
      + (known after apply),
      + (known after apply),
    ]
  + processing_role_arn    = (known after apply)
  + s3_endpoint_id         = (known after apply)
  + vpc_id                 = (known after apply)

─────────────────────────────────────────────────────────────────────────────

Saved the plan to: dev.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "dev.tfplan"
```

## tflocal apply

```text

Warning: Deprecated Parameter

The parameter "dynamodb_table" is deprecated. Use parameter "use_lockfile"
instead.
module.identity.aws_iam_role.audit: Creating...
module.identity.aws_iam_role.processing: Creating...
module.network.aws_vpc.this: Creating...
module.identity.aws_iam_role.audit: Creation complete after 0s [id=pulso-dev-audit-role]
module.identity.aws_iam_role_policy.audit_read: Creating...
module.identity.aws_iam_role.processing: Creation complete after 0s [id=pulso-dev-processing-role]
module.identity.aws_iam_role_policy.processing_s3: Creating...
module.identity.aws_iam_role_policy.audit_read: Creation complete after 0s [id=pulso-dev-audit-role:pulso-dev-audit-read]
module.identity.aws_iam_role_policy.processing_s3: Creation complete after 0s [id=pulso-dev-processing-role:pulso-dev-processing-s3]
module.network.aws_vpc.this: Creation complete after 0s [id=vpc-abf4a61e3dc395fa5]
module.network.aws_route_table.private: Creating...
module.network.aws_subnet.private["us-east-1a"]: Creating...
module.network.aws_subnet.private["us-east-1b"]: Creating...
module.network.aws_subnet.private["us-east-1b"]: Creation complete after 0s [id=subnet-b20a621b29934b26b]
module.network.aws_subnet.private["us-east-1a"]: Creation complete after 0s [id=subnet-0e97a19c0c4eac619]
module.network.aws_route_table.private: Creation complete after 1s [id=rtb-a196a0b22abb24c56]
module.network.aws_route_table_association.private["us-east-1b"]: Creating...
module.network.aws_route_table_association.private["us-east-1a"]: Creating...
module.network.aws_vpc_endpoint.s3: Creating...
module.network.aws_route_table_association.private["us-east-1a"]: Creation complete after 0s [id=rtbassoc-c3915386cbf2b1ba2]
module.network.aws_route_table_association.private["us-east-1b"]: Creation complete after 0s [id=rtbassoc-38e54a11ef07cf59b]
module.network.aws_vpc_endpoint.s3: Creation complete after 5s [id=vpce-324448a1581f0f397]

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

audit_role_arn = "arn:aws:iam::000000000000:role/pulso-dev-audit-role"
private_route_table_id = "rtb-a196a0b22abb24c56"
private_subnet_ids = [
  "subnet-0e97a19c0c4eac619",
  "subnet-b20a621b29934b26b",
]
processing_role_arn = "arn:aws:iam::000000000000:role/pulso-dev-processing-role"
s3_endpoint_id = "vpce-324448a1581f0f397"
vpc_id = "vpc-abf4a61e3dc395fa5"
```

## aws ec2 describe-vpc-endpoints (estado available)

```json
{
    "VpcEndpoints": [
        {
            "VpcEndpointId": "vpce-324448a1581f0f397",
            "VpcEndpointType": "Gateway",
            "VpcId": "vpc-abf4a61e3dc395fa5",
            "ServiceName": "com.amazonaws.us-east-1.s3",
            "State": "available",
            "PolicyDocument": "{\"Statement\": [{\"Action\": [\"s3:PutObject\", \"s3:ListBucket\", \"s3:GetObject\"], \"Effect\": \"Allow\", \"Principal\": \"*\", \"Resource\": [\"arn:aws:s3:::pulso-lakehouse-dev/*\", \"arn:aws:s3:::pulso-lakehouse-dev\"], \"Sid\": \"OnlyDataBuckets\"}]}",
            "RouteTableIds": [
                "rtb-a196a0b22abb24c56"
            ],
            "SubnetIds": [],
            "Groups": [],
            "IpAddressType": "ipv4",
            "DnsOptions": {
                "DnsRecordIpType": "ipv4"
            },
            "PrivateDnsEnabled": false,
            "RequesterManaged": false,
            "NetworkInterfaceIds": [],
            "DnsEntries": [],
            "CreationTimestamp": "2026-11-26T01:01:20+00:00",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "pulso-dev-s3-endpoint"
                },
                {
                    "Key": "Environment",
                    "Value": "dev"
                },
                {
                    "Key": "ManagedBy",
                    "Value": "terraform"
                },
                {
                    "Key": "Project",
                    "Value": "pulso-plataforma-datos"
                }
            ],
            "OwnerId": "000000000000"
        }
    ]
}
```
