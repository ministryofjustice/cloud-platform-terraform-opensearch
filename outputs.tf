output "proxy_url" {
  description = "URL for opensearch-proxy service"
  value       = "http://${kubernetes_service.proxy.metadata[0].name}.${kubernetes_service.proxy.metadata[0].namespace}.svc.cluster.local:${kubernetes_service.proxy.spec[0].port[0].port}"
}

output "snapshot_role_arn" {
  description = "Snapshot role ARN"
  value       = aws_iam_role.snapshot.arn
}