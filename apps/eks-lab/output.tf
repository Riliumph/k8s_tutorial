output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "nginx_lb_hostname" {
  value = try(
    kubernetes_service_v1.nginx.status[0].load_balancer[0].ingress[0].hostname,
    ""
  )
}
