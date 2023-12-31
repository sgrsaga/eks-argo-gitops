# 1.1. Create a VPC
variable "vpc_name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "public_source_cidr" {
  type = list(string)
}
variable "public_source_cidr_v6" {
  type = list(string)
}


# 2. Create a Internet Gateway
variable "ig_name" {
  type = string
}

# 1.3. Create 2 Route tables
variable "public_rt" {
  type = string
}
variable "private_rt" {
  type = string
}

# 1.4. Create 3 Public Subnets
variable "public_subnets" {
  type = list(string)
}

# 1.5. Create 3 Private Subnets
variable "private_subnets" {
  type = list(string)
}

# 1.6. Create Public access Security Group
variable "public_access_sg_ingress_rules" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
  default = [

  ]
}


### EKS Cluster variables
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
variable "node_group_size" {
  type        = list(number)
  description = "Value should be desired_size,max_size, min_size and max_unavailable"
  default     = [1, 2, 1, 1]
}

# 6. Public NG size
variable "public_ng_size" {
  type    = number
  default = 1
}
# 7. Private NG size
variable "private_ng_size" {
  type    = number
  default = 1
}

# # 8. K8S version to spin up
# variable "k8s_version" {
#     type = string 
#     default = "1.28"
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


### EC2 Nodes Parameter
# 1. EC2 AMI
variable "ami_id" {
  type = string
}
# 2. Number of EC2s
variable "ec2_node_cnt" {
  type = number
}
# 3. SSH Key Name
variable "ssh_key_name" {
  type = string
}

# 4. Instance type
variable "instance_type" {
  type = string
}

# 5. Role Name
variable "role_name" {
  type = string
}
# 7. Userdata file
variable "user_data_file" {
  type = string
}
# 9. Volume size
variable "root_sorage" {
  type    = number
  default = 20
}

# 10. Master Nodes
variable "master_names" {
  type    = list(string)
  default = ["Master1"]
}
# 5. Master Type - master_names
variable "master_type" {
  type = string
}

# 11. Worker Nodes
variable "worker_names" {
  type    = list(string)
  default = ["Worker_1", "Worker_2"]
}
# 5. Worker Type - worker_names
variable "worker_type" {
  type = string
}
######################### Helm module

# Config path
variable "config_path" {
  type = string
}

# Ingress name spece
variable "ingress_ns" {
  type = string
}

# ArgoCD namespace
variable "argo_ns" {
  type    = string
  default = "argo_ns"
}

# Monitoring  namespece
variable "monitoring_ns" {
  type = string
}

# # Cert Auth Data
# variable "cert_data" {
#     type = string
#     default = "cert_data"
# }

#################### eks access module
# Developer Username
variable "devuser" {
    type = string  
}

# Admin Username
variable "adminuser" {
    type = string  
}
