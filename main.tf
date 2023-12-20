## Add the provide section.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0" ## was 5.5.0
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
}

## Providers

provider "aws" {
  region = "ap-south-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  #config_context = "my-context"
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
    key    = "eks-argo-helm.tfstate"
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
  source           = "./module/eks"
  private_ng_size  = var.private_ng_size
  public_ng_size   = var.public_ng_size
  cluster_name     = var.cluster_name
  node_group_names = var.node_group_names
  node_group_size  = var.node_group_size

  # Versions
  # version                 = var.k8s_version
  # cni-version             = var.cni-version
  # coredns-version         = var.coredns-version
  # kube-proxy-version      = var.kube-proxy-version
  # ebs-csi-version         = var.ebs-csi-version

  depends_on = [module.main_network]
}

# 3. Install Helm based utilities for the EKS
module "helm_repos" {
  source = "./module/helm"  
}