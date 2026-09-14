resource "kubectl_manifest" "nginx_deployment" {
  yaml_body = file("nginx-deployment.yaml")
}

resource "kubectl_manifest" "nginx_service" {
  yaml_body = file("nginx-service.yaml")
}
