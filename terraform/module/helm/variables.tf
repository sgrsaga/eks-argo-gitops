# # Ingress namespace
# variable "ingress_ns"{
#     type = string
#     default = "ingress"
# }

# # ArgoCD namespace
# variable "argo_ns"{
#     type = string
#     default = "argo_ns"
# }

# # Monitoring  namespece
# variable "monitoring_ns"{
#     type = string
# }


# Ingress namespece
variable "ingress_ns"{
    type = string
}


# ArgoCD  namespece
variable "argo_ns"{
    type = string
}


# Monitoring  namespece
variable "monitoring_ns"{
    type = string
}

# # Cert Auth Data
# variable "cert_data" {
#     type = string  
# }