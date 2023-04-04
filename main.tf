locals {
  # Generic configuration
  identifier = "cloud-platform-${random_id.name.hex}"
  vpc_name   = (var.vpc_name == "live") ? "live-1" : var.vpc_name

  # Tags
  default_tags = {
    # Mandatory
    business-unit = var.business_unit
    application   = var.application
    is-production = var.is_production
    owner         = var.team_name
    namespace     = var.namespace # for billing and identification purposes

    # Optional
    environment-name       = var.environment_name
    infrastructure-support = var.infrastructure_support
  }
}

#######################
# Get VPC information #
#######################
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

########################
# Generate identifiers #
########################
resource "random_id" "name" {
  byte_length = 4 # this is because there is a character limit of 24 characters per OpenSearch domain, so this generates `cloud-platform-12345678` which is 23 characters
}

##########################
# Create Security Groups #
##########################
resource "aws_security_group" "this" {
  vpc_id      = data.aws_vpc.this.id
  name        = local.identifier
  description = "Allow TLS ingress traffic via the private subnet for OpenSearch domain: ${local.identifier}"

  ingress {
    description = "TLS from the private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
  }

  egress {
    description = "Egress to the private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
  }

  tags = local.default_tags
}

############################
# Create OpenSearch domain #
############################
resource "aws_kms_key" "this" {
  description = "Used for OpenSearch: ${local.identifier}"
  key_usage   = "ENCRYPT_DECRYPT"

  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 30
  is_enabled                         = true
  enable_key_rotation                = false
  multi_region                       = false
  tags                               = local.default_tags
}

resource "aws_opensearch_domain" "this" {
  domain_name = local.identifier

  advanced_options = merge({
    "rest.action.multi.allow_explicit_index" = "true"
  }, var.advanced_options)

  dynamic "cluster_config" {
    for_each = [var.cluster_config]

    content {
      # Dedicated primary nodes
      dedicated_master_count   = try(cluster_config.value["dedicated_master_enabled"], false) ? cluster_config.value["dedicated_master_count"] : null
      dedicated_master_enabled = try(cluster_config.value["dedicated_master_enabled"], false) ? cluster_config.value["dedicated_master_enabled"] : false
      dedicated_master_type    = try(cluster_config.value["dedicated_master_enabled"], false) ? cluster_config.value["dedicated_master_type"] : null

      # Instances
      instance_count = cluster_config.value["instance_count"]
      instance_type  = cluster_config.value["instance_type"]

      # Warm storage
      warm_count   = try(cluster_config.value["warm_enabled"], false) ? cluster_config.value["warm_count"] : null
      warm_enabled = try(cluster_config.value["warm_enabled"], false) ? cluster_config.value["warm_enabled"] : false
      warm_type    = try(cluster_config.value["warm_enabled"], false) ? cluster_config.value["warm_type"] : null

      # Zone awareness
      zone_awareness_enabled = true
      zone_awareness_config {
        availability_zone_count = (cluster_config.value["instance_count"] < 3) ? 2 : 3 # 2 AZs for 2 instances, 3 for anything higher
      }
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07" # default to TLS 1.2
  }

  dynamic "ebs_options" {
    for_each = [var.ebs_options]

    content {
      ebs_enabled = true

      iops        = try(ebs_options.value["iops"], 3000) # these are AWS defaults
      throughput  = try(ebs_options.value["throughput"], 125) # these are AWS defaults
      volume_size = ebs_options.value["volume_size"]
      volume_type = "gp3"
    }
  }

  engine_version = var.engine_version

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.this.key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    security_group_ids = [aws_security_group.this.id]
    subnet_ids         = (var.cluster_config["instance_count"] < 3) ? slice(data.aws_subnets.private.ids, 0, 2) : data.aws_subnets.private.ids
  }

  tags = local.default_tags
}

# Allow access for the Kubernetes cluster/IRSA
data "aws_iam_policy_document" "domain_policy" {
  statement {
    effect = "Allow"
    actions = [
      "es:ESHttp*"
    ]
    resources = [
      "${aws_opensearch_domain.this.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [module.irsa.aws_iam_role_arn]
    }
  }
}

resource "aws_opensearch_domain_policy" "this" {
  domain_name     = aws_opensearch_domain.this.domain_name
  access_policies = data.aws_iam_policy_document.domain_policy.json
}
