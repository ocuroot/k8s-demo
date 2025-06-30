resource "vultr_kubernetes" "k8" {
    region  = "ewr"
    label   = local.env_name
    version = "v1.33.0+1"

    node_pools {
        node_quantity = 2
        plan          = "vc2-1c-2gb"
        label         = "vke-nodepool"
        auto_scaler   = true
        min_nodes     = var.min_nodes
        max_nodes     = var.max_nodes
    }

    lifecycle {
      ignore_changes = [
        # Don't change the number of nodes after autoscaling
        node_pools[0].node_quantity
      ]
    }
}

resource "local_file" "kubeconfig" {
  content  = base64decode(vultr_kubernetes.k8.kube_config)
  filename = "${path.module}/../.state/${var.environment}/kubeconfig"
}