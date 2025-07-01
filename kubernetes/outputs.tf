output "env_name" {
  value = local.env_name
}

output "kubeconfig" {
  value = digitalocean_kubernetes_cluster.k8.kube_config.0.raw_config
  sensitive = true
}