
## Module - main_network
output "vpc_id" {
  value = module.main_network.vpc_id
}

output "public_route_ids" {
  value = module.main_network.public_rt
}


output "private_route_ids" {
  value = module.main_network.private_rt
}


output "public_subnet_ids" {
  value = module.main_network.public_subnet_list
}


output "private_subnet_list" {
  value = module.main_network.private_subnet_list
}


output "public_security_group" {
  value = module.main_network.public_security_group
}


output "private_security_group" {
  value = module.main_network.private_security_group
}

# EKS Cluster details
# EKS cluster endpoiny
output "eks_cluster_endpoint" {
  value = module.eks_gitops_cluster.eks_cluster_endpoint

}


## HELM repo details
# Argo cd Manifest
## Check Argo manifest file
output "manifest_files_yaml" {
  value = module.helm_repos.manifest_files
}

## Final Values
output "final_values" {
  value = module.helm_repos.final_values
}

## Get Zone ID
output "zone_id" {
    value =  module.helm_repos.zone_id
}
## Get NLB DNS Name
output "nlb_dns_name" {
    value = module.helm_repos.nlb_dns_name
}
/*
## EIP details
output "eip_allocation_id" {
  value = module.main_network.eip_allocation_id
  #value = aws_eip.nat_public_ip.allocation_id
}
# #NAT GATEWAY details
output "aws_nat_gateway" {
  value = module.main_network.aws_nat_gateway
  #value = aws_nat_gateway.gateway_for_private_sn.id
}

######## Databse and DB Prosy related ##################
## Address URL and PORT
output "db_url" {
  value = module.pg_database.db_url
}
## Storage amount
output "storage_value" {
  value = module.pg_database.storage_value
}
## Address URL:PORT
output "db_endpoint" {
  value = module.pg_database.db_endpoint
}

## IAM
output "iam_role" {
  value = module.pg_database.iam_role
}
## USERNAME
output "db_username" {
  value = module.pg_database.db_username
}
## Multi AZs
output "multi_az_check" {
  value = module.pg_database.multi_az_check
}
## Backup retention eriod
output "back_retention" {
  value = module.pg_database.back_retention
}
## DB Subnet group linked subnet IDs
output "db_subnet_group_subnet_ids" {
  value = module.pg_database.db_subnet_group_subnet_ids
}


######## Cognito userpool details
## App Client ID
output "app_client_clientid" {
    value = module.cognito.app_client_clientid
}
## User pool id
output "user_pool_id" {
  value = module.cognito.user_pool_id
}
## User pool arn
output "user_pool_arn" {
  value = module.cognito.pool_arn
}
*/