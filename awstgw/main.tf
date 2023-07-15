terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_ec2_transit_gateway" "use1-tgw" {

    tags = {
        Name = "var.tgw_name"
    }
}
# Attach TVPC to transit gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tvpc_attach" {
    transit_gateway_id = data.aws_ec2_transit_gateway.use1-tgw.id
    vpc_id = var.tvpc_id
    subnet_ids = [var.private_a_subnet_id,var.private_b_subnet_id]
     tags = {
  Name = "TGW-TVPC"
 }
}
# Create connect connection
resource "aws_ec2_transit_gateway_connect" "gre" {
    transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tvpc_attach.id
    transit_gateway_id = data.aws_ec2_transit_gateway.use1-tgw.id
     tags = {
  Name = "TGW-TVPC-GRE"
 }
}
# Create peer to cloud gateway1
resource "aws_ec2_transit_gateway_connect_peer" "gw1" {
    peer_address = var.gw1_gre_src_ip
    inside_cidr_blocks = ["169.254.6.0/29"]
    transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.gre.id
    bgp_asn = 64513
     tags = {
  Name = "BGPGW1"
 }
}
resource "aws_ec2_transit_gateway_connect_peer" "gw2" {
    peer_address = var.gw2_gre_src_ip
    inside_cidr_blocks = ["169.254.6.8/29"]
    transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.gre.id
    bgp_asn = 64513
     tags = {
  Name = "BGPGW2"
 }
}