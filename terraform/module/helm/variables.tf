# Ingress namespace
variable "ingress_ns"{
    type = string
    default = "ingress"
}

# ArgoCD namespace
variable "argo_ns"{
    type = string
    default = "argo_ns"
}

# Monitoring  namespece
variable "monitoring_ns"{
    type = string
}