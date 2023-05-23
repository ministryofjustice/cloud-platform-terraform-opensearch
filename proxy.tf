resource "kubernetes_deployment" "proxy" {
  metadata {
    name      = "opensearch-proxy-${local.identifier}"
    namespace = var.namespace

    labels = {
      app = "opensearch-proxy"
    }
  }

  spec {
    replicas = var.proxy_count

    selector {
      match_labels = {
        app = "opensearch-proxy-${local.identifier}"
      }
    }

    template {
      metadata {
        labels = {
          app = "opensearch-proxy-${local.identifier}"
        }
      }

      spec {
        service_account_name = module.irsa.service_account_name.name
        container {
          image = "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.7"
          name  = "opensearch-proxy"

          security_context {
            allow_privilege_escalation = false
            run_as_non_root            = true
            run_as_user                = 10001
          }

          port {
            container_port = 9200
          }

          args = [
            "-endpoint",
            format(
              "https://%s",
              aws_opensearch_domain.this.endpoint,
            ),
            "-listen",
            ":9200"
          ]
        }
      }
    }
  }
}

resource "kubernetes_service" "proxy" {
  metadata {
    name      = "opensearch-proxy-service-${local.identifier}"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "opensearch-proxy-${local.identifier}"
    }

    port {
      port        = 9200
      target_port = 9200
    }
  }
}
