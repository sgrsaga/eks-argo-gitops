## Add the provide section.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0" ## was 5.5.0
    }
  }
}

/*
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
*/


terraform {
  backend "s3" {
    bucket = "terraform-state-files-sgr-jay"
    key    = "eks-argo.tfstate"
    region = "ap-south-1"
  }
}


/*
## Terraform Backend
terraform {
  backend "remote" {
    organization = "home_org_sagara"
    hostname = "app.terraform.io"
    workspaces {
      name = "k8s_infra"
    }
  }
}
*/

provider "aws" {
  region = "ap-south-1"
}


# 1. Call the main network module
module "main_network" {
  source                         = "./module/main_network"
  vpc_name                       = var.vpc_name
  vpc_cidr                       = var.vpc_cidr
  public_source_cidr             = var.public_source_cidr
  public_source_cidr_v6          = var.public_source_cidr_v6
  ig_name                        = var.ig_name
  public_subnets                 = var.public_subnets
  private_subnets                = var.private_subnets
  public_access_sg_ingress_rules = var.public_access_sg_ingress_rules
  public_rt                      = var.public_rt
  private_rt                     = var.private_rt
}



# 2. EKS Cluster creation
module "eks_gitops_cluster" {
  source                  = "./module/eks"
  cluster_subnets         = module.main_network.private_subnet_list
  cluster_security_group  = [module.main_network.public_security_group]
  cluster_name            = var.cluster_name
  node_group_names        = var.node_group_names
  node_group_size         = var.node_group_size

  depends_on              = [ module.main_network ]
}