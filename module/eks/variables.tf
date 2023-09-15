# 1. EKS Cluster name
variable "cluster_name" {
    type = string
    default = "MyEKS_Cluster" 
}

# 2. EKS Cluster subnets
variable "cluster_subnets" {
    type = list(string)
    default = ["sub1"]
  
}

# 3. EKS Cluster security group
variable "cluster_security_group" {
    type = list()
    default = ["sg1"]
  
}