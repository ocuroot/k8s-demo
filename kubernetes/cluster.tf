resource "digitalocean_kubernetes_cluster" "k8" {
    name    = local.env_name
    region  = "nyc1"  # New York region (closest equivalent to Vultr's ewr)
    version = "1.31.9-do.1"  # Using a recent stable version

    node_pool {
        name       = "worker-pool-${local.env_name}"
        size       = "s-1vcpu-2gb"  # Equivalent to Vultr's 1c-2gb instance
        node_count = 1
        auto_scale = false
    }
}
