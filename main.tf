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



