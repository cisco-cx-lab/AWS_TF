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

#module to creat vpc resources and provision cloud gateways
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

#module to creat vpc attachment to existing tgw and build bgp peer
module "awstgw"{
 source = "./modules/awstgw"
 tgw_name = var.tgw_name
 tvpc_id = module.awsvpc.output_tvpc_id
 private_a_subnet_id = module.awsvpc.output_private_a_subnet_id
 private_b_subnet_id = module.awsvpc.output_private_b_subnet_id
 gw1_gre_src_ip = module.awsvpc.output_gw1_gre_src_ip
 gw2_gre_src_ip = module.awsvpc.output_gw2_gre_src_ip
}