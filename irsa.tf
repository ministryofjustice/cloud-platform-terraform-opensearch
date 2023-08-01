data "aws_iam_policy_document" "irsa" {
  statement {
    effect = "Allow"
    actions = [
      "es:ESHttpHead",
      "es:ESHttpPost",
      "es:ESHttpGet",
      "es:ESHttpPatch",
      "es:ESHttpDelete",
      "es:ESHttpPut"
    ]

    resources = [
      "${aws_opensearch_domain.this.arn}/*"
    ]
  }

  # for snapshots
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.snapshot.arn]
  }
}

resource "aws_iam_policy" "irsa" {
  name        = local.identifier
  description = "IRSA policy for OpenSearch: ${local.identifier}"
  policy      = data.aws_iam_policy_document.irsa.json

  tags = local.default_tags
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment_name}"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    opensearch = aws_iam_policy.irsa.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}
