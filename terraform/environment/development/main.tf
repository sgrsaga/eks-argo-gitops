terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-files-sgr-jay"
    key            = "eks-argo-gitops/development/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Environment = "development"
    Project     = "eks-gitops"
    ManagedBy   = "Terraform"
    Repository  = "eks-argo-gitops"
  }
}

provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = local.common_tags
  }
}

provider "helm" {
  kubernetes {
    config_path = var.config_path
  }
}

provider "kubernetes" {
  config_path = var.config_path
}

# 1. Call the main network module
module "main_network" {
  source                         = "../../module/main_network"
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
  source           = "../../module/eks_cluster"
  cluster_name     = var.cluster_name
  node_group_names = var.node_group_names
  node_group_size1 = var.node_group_size1
  node_group_size2 = var.node_group_size2
  k8s_version      = var.k8s_version

  allowed_eks_public_cidrs = var.allowed_eks_public_cidrs

  depends_on = [module.main_network]
}

# 3. Install Helm based utilities for the EKS
module "helm_repos" {
  source                = "../../module/helm"
  eks_cluster_name      = module.eks_gitops_cluster.eks_cluster_name
  oidc_iam_provider_arn = module.eks_gitops_cluster.oidc_iam_provider_arn
  oidc_iam_provider_url = module.eks_gitops_cluster.oidc_iam_provider_url
  ingress_ns            = var.ingress_ns
  cluster_vpc_id        = module.main_network.vpc_id
  cluster_region        = var.cluster_region

  depends_on = [module.eks_gitops_cluster]
}
