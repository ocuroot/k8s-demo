resource "random_id" "suffix" {
  byte_length = 8
}

locals {
    env_name = "ocuroot-${var.environment}-${random_id.suffix.hex}"
}