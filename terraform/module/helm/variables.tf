variable "cluster_vpc_id" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_iam_provider_arn" {
  description = "ARN of the OIDC IAM provider for the EKS cluster"
  type        = string
}

variable "oidc_iam_provider_url" {
  description = "URL of the OIDC IAM provider for the EKS cluster"
  type        = string
}

# # Monitoring  namespece
# variable "monitoring_ns"{
#     type = string
# }

# # Domain name
# variable "domain_name_used"{
#     type = string
# }

# # Domain aleternate names
# variable "alt_names"{
#     type = list(string)
# }
# # Domain alt_names_prefix names
# variable "alt_names_prefix"{
#     type = list(string)
# }
# # alias_zone_id
# variable "alias_zone_id" {
#     type = string  
# }

# Ingress namespece
variable "ingress_ns"{
    type = string
}

# # ArgoCD  namespece
# variable "argo_ns"{
#     type = string
# }


# # Monitoring  namespece
# variable "monitoring_ns"{
#     type = string
# }

# # Cert Auth Data
# variable "cert_data" {
#     type = string  
# }