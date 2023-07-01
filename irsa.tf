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
}

resource "aws_iam_policy" "irsa" {
  name        = local.identifier
  description = "IRSA policy for OpenSearch: ${local.identifier}"
  policy      = data.aws_iam_policy_document.irsa.json

  tags = local.default_tags
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace
  role_policy_arns = [aws_iam_policy.irsa.arn]
}
