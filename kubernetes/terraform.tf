terraform {
    required_version = ">= 1.6.3"

    required_providers {
        vultr = {
            source = "vultr/vultr"
            version = "2.21.0"
        }
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "2.36.0"
        }
        local = {
            source = "hashicorp/local"
            version = "2.1.0"
        }
        random = {
            source = "hashicorp/random"
            version = "3.6.2"
        }
        google = {
            source = "hashicorp/google"
            version = "6.14.1"
        }
    }

    backend "gcs" {
        bucket  = "ocuroot-terraform-backends"
        project = "hosted-ocuroot"
    }
}

provider "google" {
  project     = "hosted-ocuroot"
  region      = "us-west1"
}

# Configure the Vultr Provider
provider "vultr" {
  api_key = var.vultr_api_key
  rate_limit = 100
  retry_limit = 3
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}
