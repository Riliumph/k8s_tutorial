resource "kubernetes_deployment_v1" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [
    aws_eks_node_group.this
  ]
}

resource "kubernetes_service_v1" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
