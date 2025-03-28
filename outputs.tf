output "proxy_url" {
  description = "URL for opensearch-proxy service"
  value       = "http://${kubernetes_service.proxy.metadata[0].name}.${kubernetes_service.proxy.metadata[0].namespace}.svc.cluster.local:${kubernetes_service.proxy.spec[0].port[0].port}"
}

output "snapshot_role_arn" {
  description = "Snapshot role ARN"
  value       = aws_iam_role.snapshot.arn
}

output "irsa_role_arn" {
  description = "Service account role ARN"
  value       = module.irsa.role_arn
}

output "service_account_name" {
  description = "Service account name"
  value       = module.irsa.service_account.name
}

output "domain_arn" {
  description = "OpenSearch domain ARN"
  value       = aws_opensearch_domain.this.arn
}

output "domain_name" {
  description = "OpenSearch domain name"
  value       = aws_opensearch_domain.this.domain_name
}

output "endpoint" {
  description = "OpenSearch VPC endpoint"
  value       = aws_opensearch_domain.this.endpoint
}
