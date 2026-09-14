output "cluster_name" {
  value = aws_eks_cluster.this.name
}

# ===============================================

## kubernetes_service_v1を使用停止。
## kubectlで制御する方法を採用。
# output "nginx_lb_hostname" {
#   value = try(
#     kubernetes_service_v1.nginx.status[0].load_balancer[0].ingress[0].hostname,
#     ""
#   )
# }
