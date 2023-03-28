# cloud-platform-terraform-opensearch

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-opensearch/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-opensearch/releases)

This Terraform module will create an [AWS OpenSearch](https://aws.amazon.com/opensearch-service/) domain for use on the Cloud Platform.

It also creates an [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to allow access via your Cloud Platform namespace pods, and a [proxy webserver](https://github.com/abutaha/aws-es-proxy) to automatically sign requests to your OpenSearch domain from your pods.

## Usage

```hcl
module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=version" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version = "OpenSearch_1.0"

  cluster_config   = {
    instance_count = 3
    instance_type  = "t3.medium.search"
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
```

See the [examples/](examples/) folder for more information.

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->

## Tags

Some of the inputs for this module are tags. All infrastructure resources must be tagged to meet the MOJ Technical Guidance on [Documenting owners of infrastructure](https://technical-guidance.service.justice.gov.uk/documentation/standards/documenting-infrastructure-owners.html).

You should use your namespace variables to populate these. See the [Usage](#usage) section for more information.

## Reading Material

- [Cloud Platform user guide](https://user-guide.cloud-platform.service.justice.gov.uk/#cloud-platform-user-guide)
- [AWS OpenSearch developer guide](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/what-is.html)
