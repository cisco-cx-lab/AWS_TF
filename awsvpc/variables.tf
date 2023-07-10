variable "cidr_block" {
description = "aws cidr for the vpc"
}
variable "vpc_name" {
description = "name tag for the vpc"
}
variable "vpc_subnets" {
description = "list of subnets in vpc"
type = list(object({
subnet = string
name = string
az = string
}))
}
variable "vpc_gw"{
description = "internet gateway"
}
variable "vpc_rt" {
  type = list
}
variable "sg_name" {
  type = string
}
variable "cloud_gateway" {
  description = "cloud router name"
  type = list(object({

  name = string
  cloudinit = string
}))
}