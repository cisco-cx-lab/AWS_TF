terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Create a Transit VPC to launch the redundant cloud gateways 
resource "aws_vpc" "vpc" {
cidr_block = var.cidr_block
tags = {
 Name = var.vpc_name
}
}

# Set up four subnets within the Transit VPC to segregate the network traffic.
resource "aws_subnet" "subnets" {
  for_each = {for index, net in var.vpc_subnets: net.name => net}
  cidr_block = each.value["subnet"]
  tags = {
   Name = each.value["name"]
  }
  vpc_id = aws_vpc.vpc.id
  availability_zone = each.value["az"]
}

# Create IGW for public route table
resource "aws_internet_gateway" "gw" {

 vpc_id = aws_vpc.vpc.id

 tags = {
  Name = var.vpc_gw
 }
}

# Create four separate route tables, one for each subnet, to define the routing behavior
resource "aws_route_table" "rt" {
 vpc_id = aws_vpc.vpc.id
 for_each = toset(var.vpc_rt)
 tags = {
  Name = each.value
 }
}

# Associate IGW to public rt
resource "aws_route_table_association" "gateway" {
  gateway_id = aws_internet_gateway.gw.id
  route_table_id = aws_route_table.rt["public"].id
}

# Associate subnets with the appropriate route tables
resource "aws_route_table_association" "public-a" {
  subnet_id = aws_subnet.subnets["use1-public-a"].id
  route_table_id = aws_route_table.rt["public"].id
}
resource "aws_route_table_association" "public-b" {
subnet_id = aws_subnet.subnets["use1-public-b"].id
route_table_id = aws_route_table.rt["public"].id
}
resource "aws_route_table_association" "private-a" {
subnet_id = aws_subnet.subnets["use1-private-a"].id
route_table_id = aws_route_table.rt["private"].id
}
resource "aws_route_table_association" "private-b" {
subnet_id = aws_subnet.subnets["use1-private-b"].id
route_table_id = aws_route_table.rt["private"].id
}
resource "aws_route_table_association" "mgmt-a" {
subnet_id = aws_subnet.subnets["use1-mgmt-a"].id
route_table_id = aws_route_table.rt["private"].id
}
resource "aws_route_table_association" "mgmt-b" {
subnet_id = aws_subnet.subnets["use1-mgmt-b"].id
route_table_id = aws_route_table.rt["private"].id
}
resource "aws_route_table_association" "service-a" {
subnet_id = aws_subnet.subnets["use1-service-a"].id
route_table_id = aws_route_table.rt["private"].id
}
resource "aws_route_table_association" "service-b" {
subnet_id = aws_subnet.subnets["use1-service-b"].id
route_table_id = aws_route_table.rt["private"].id
}
# Configure SG to allow sdwan traffic
resource "aws_security_group" "allow_sdwan"{
name = var.sg_name
description = "SG to allow sdwan"
vpc_id = aws_vpc.vpc.id

ingress {
  protocol  = -1
  self      = true
  from_port = 0
  to_port   = 0
}

egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}

# Create four Network Interfaces for each cloud gateway
resource "aws_network_interface" "public_nics-a" {
subnet_id = aws_subnet.subnets["use1-public-a"].id
  security_groups = [aws_security_group.allow_sdwan.id]
    tags             ={
    Name           ="public_nics-a"
                     }  
}

resource "aws_network_interface" "private_nics-a" {
subnet_id = aws_subnet.subnets["use1-private-a"].id
  
  tags             ={
    Name           ="private_nics-a"
                     }  
}

resource "aws_network_interface" "service_nics-a" {
subnet_id = aws_subnet.subnets["use1-service-a"].id
  
   tags            ={
    Name           ="service_nics-a"
                     }  
}
resource "aws_network_interface" "mgmt_nics-a" {
subnet_id = aws_subnet.subnets["use1-mgmt-a"].id
  
  tags             ={
    Name           ="mgmt_nics-a"
                     }  
}
resource "aws_network_interface" "public_nics-b" {
subnet_id = aws_subnet.subnets["use1-public-b"].id
  security_groups = [aws_security_group.allow_sdwan.id]
    tags             ={
    Name           ="public_nics-b"
                     }  
}

resource "aws_network_interface" "private_nics-b" {
subnet_id = aws_subnet.subnets["use1-private-b"].id
  
  tags             ={
    Name           ="private_nics-b"
                     }  
}

resource "aws_network_interface" "service_nics-b" {
subnet_id = aws_subnet.subnets["use1-service-b"].id
  
   tags            ={
    Name           ="service_nics-b"
                     }  
}
resource "aws_network_interface" "mgmt_nics-b" {
subnet_id = aws_subnet.subnets["use1-mgmt-b"].id
  
  tags             ={
    Name           ="mgmt_nics-b"
                     }  
}

# Create Elastic IP for public network interface
resource "aws_eip" "eip_a" {
  network_interface = aws_network_interface.public_nics-a.id
}

resource "aws_eip" "eip_b" {
  network_interface = aws_network_interface.public_nics-b.id
}

# Deploy cloud gateway with the startup configuration
resource "aws_instance" "cisco_cat800v_instance1" {
 ami                         ="ami-0e0b8922c216d76dd"
 instance_type               ="c5.xlarge"
user_data = filebase64("${path.module}/../../bootstrap/${var.cloud_gateway[0].cloudinit}")
 root_block_device { 
     volume_size           	=16
     volume_type           	="gp2"
     delete_on_termination	=true
   }
tags = {
name = "var.cloud_gateway[0].name"
}
 ebs_block_device { 
     device_name 			= "/dev/sda1"
     volume_size 			=16
     volume_type 			= "gp2"
     delete_on_termination=true
   }

 network_interface { 
     device_index         				=0
     network_interface_id 				= aws_network_interface.public_nics-a.id 
 }
network_interface {
     device_index         				=1
     network_interface_id 				= aws_network_interface.private_nics-a.id
    }
network_interface {    
        device_index         				=2
     network_interface_id 				= aws_network_interface.service_nics-a.id
    }
    network_interface {
          device_index         				=3
     network_interface_id 				= aws_network_interface.mgmt_nics-a.id             
   } 
} 
resource "aws_instance" "cisco_cat800v_instance2" {
 ami                         ="ami-0e0b8922c216d76dd"
 instance_type               ="c5.xlarge"
user_data = filebase64("${path.module}/../../bootstrap/${var.cloud_gateway[1].cloudinit}")
tags ={
Name = "var.cloud_gateway[1].name"
}
 root_block_device { 
     volume_size           	=16
     volume_type           	="gp2"
     delete_on_termination	=true
   }

 ebs_block_device { 
     device_name 			= "/dev/sda1"
     volume_size 			=16
     volume_type 			= "gp2"
     delete_on_termination=true
   }

 network_interface { 
     device_index         				=0
     network_interface_id 				= aws_network_interface.public_nics-b.id 
 }
network_interface {
     device_index         				=1
     network_interface_id 				= aws_network_interface.private_nics-b.id
    }
network_interface {    
        device_index         				=2
     network_interface_id 				= aws_network_interface.service_nics-b.id
    }
    network_interface {
          device_index         				=3
     network_interface_id 				= aws_network_interface.mgmt_nics-b.id             
   } 
}