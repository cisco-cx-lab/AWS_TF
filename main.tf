terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
access_key = var.aws_key
secret_key = var.aws_secret
region = var.aws_region
}

module "awsvpc"{
 source = "./modules/awsvpc"
 cidr_block = var.cidr_block
 vpc_name = var.vpc_name
 vpc_subnets = var.vpc_subnets
 vpc_gw = var.vpc_gw
 vpc_rt = var.vpc_rt
 sg_name = var.sg_name
 cloud_gateway = var.cloud_gateway
 }
