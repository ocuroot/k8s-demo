variable environment {
    type = string
}

variable vultr_api_key {
    type = string
    sensitive = true
}

variable min_nodes {
    type = number
    default = 2
}

variable max_nodes {
    type = number
    default = 4
}