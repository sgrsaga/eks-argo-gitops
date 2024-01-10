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
    type = list(string)
    default = ["sg1"]
}

# 4. Node Group Names
variable "node_group_names" {
    type = list(string)
    default = ["NG1"]
}

# 5. Node Group Thresholds
variable "node_group_size1" {
    type = list(number)
    description = "Value should be desired_size,max_size, min_size and max_unavailable"
    default = [1,2,1,1]
}
# 6. Node Group Thresholds
variable "node_group_size2" {
    type = list(number)
    description = "Value should be desired_size,max_size, min_size and max_unavailable"
    default = [1,2,1,1]
}

# # 8. K8S version to spin up
# variable "k8s_version" {
#     type = string
# }

# # 9. CNI version
# variable "cni-version" {
#     type = string  
# }

# # 10. CoreDNS version
# variable "coredns-version" {
#     type = string  
# }

# # 11. KubeProxy version
# variable "kube-proxy-version" {
#     type = string  
# }

# # 12. EBS CSI version
# variable "ebs-csi-version" {
#     type = string  
# }