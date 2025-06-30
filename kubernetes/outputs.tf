output "env_name" {
  value = local.env_name
}

output "kubeconfig" {
  value = base64decode(vultr_kubernetes.k8.kube_config)
  sensitive = true
}