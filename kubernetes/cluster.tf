resource "vultr_kubernetes" "k8" {
    region  = "ewr"
    label   = local.env_name
    version = "v1.33.0+1"

    node_pools {
        node_quantity = 1
        plan          = "vc2-1c-1gb"
        label         = "vke-nodepool"
    }

    lifecycle {
      ignore_changes = [
        # Don't change the number of nodes after autoscaling
        node_pools[0].node_quantity
      ]
    }
}
