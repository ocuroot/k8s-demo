resource "random_id" "suffix" {
  byte_length = 8
}

locals {
    env_name = "ocuroot-${var.environment}-${random_id.suffix.hex}"
}

resource "local_file" "env_name" {
  content  = local.env_name
  filename = "${path.module}/../.state/${var.environment}/env_name.txt"
}