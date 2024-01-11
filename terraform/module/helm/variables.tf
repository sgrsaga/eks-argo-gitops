# Monitoring  namespece
variable "monitoring_ns"{
    type = string
}


# Domain name
variable "domain_name_used"{
    type = string
}

# Domain aleternate names
variable "alt_names"{
    type = list(string)
}
# Domain alt_names_prefix names
variable "alt_names_prefix"{
    type = list(string)
}
# alias_zone_id
variable "alias_zone_id" {
    type = string  
}

# Ingress namespece
variable "ingress_ns"{
    type = string
}

# ArgoCD  namespece
variable "argo_ns"{
    type = string
}


# # Monitoring  namespece
# variable "monitoring_ns"{
#     type = string
# }

# # Cert Auth Data
# variable "cert_data" {
#     type = string  
# }