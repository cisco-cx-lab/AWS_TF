variable "aws_region" {
description = "aws region"
type = string
}

variable "aws_key" {
description = "aws IAM key"
type = string
sensitive = true
}
variable "aws_secret" {
description = "aws IAM key secret"
type = string
sensitive = true
}
variable "vpc_name" {
description = "name tag for the vpc"
}
variable "cidr_block" {
description = "aws cidr for the vpc"
}
variable "vpc_subnets"{
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
description = "vpc route table"
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