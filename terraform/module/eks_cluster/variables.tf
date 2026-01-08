# 1. EKS Cluster name
variable "cluster_name" {
  type    = string
  default = "MyEKS_Cluster"
}

# 2. EKS Cluster subnets
variable "cluster_subnets" {
  type    = list(string)
  default = ["sub1"]
}

# 3. EKS Cluster security group
variable "cluster_security_group" {
  type    = list(string)
  default = ["sg1"]
}

# 4. Node Group Names
variable "node_group_names" {
  type    = list(string)
  default = ["NG1"]
}

# 5. Node Group Thresholds
variable "node_group_size1" {
  type        = list(number)
  description = "Value should be desired_size,max_size, min_size and max_unavailable"
  default     = [1, 2, 1, 1]
}

# 6. Node Group Thresholds
variable "node_group_size2" {
  type        = list(number)
  description = "Value should be desired_size,max_size, min_size and max_unavailable"
  default     = [1, 2, 1, 1]
}

# 8. K8S version to spin up
variable "k8s_version" {
  type = string
}

# 9. Allowed CIDR blocks for EKS public endpoint access
variable "allowed_eks_public_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access EKS public endpoint"
  default     = ["0.0.0.0/0"]
}

# EKS Addons
variable "eks_addons" {
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "coredns"
      version = "v1.12.1-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.21.1-eksbuild.1"
    },
    {
      name    = "kube-proxy"
      version = "v1.33.5-eksbuild.2"
    },
    {
      name    = "external-dns"
      version = "v0.20.0-eksbuild.2"
    },
    {
      name    = "cert-manager"
      version = "v1.19.2-eksbuild.1"
    },
  ]
}
