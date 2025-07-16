output "env_name" {
  value = local.env_name
}

output "kubeconfig" {
  value = digitalocean_kubernetes_cluster.k8.kube_config.0.raw_config
  sensitive = true
}

output "kubeconfig_sha256" {
  value = sha256(digitalocean_kubernetes_cluster.k8.kube_config.0.raw_config)
  sensitive = true
}