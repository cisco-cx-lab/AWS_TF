
variable "tgw_name"{
  description = "exiting tgw"
  type = string
}
variable "tvpc_id" {
  type = string
}
variable "private_a_subnet_id" {
  type = string
} 
variable "private_b_subnet_id" {
  type = string
}
variable "gw1_gre_src_ip" {
  type = string
}
 
 variable "gw2_gre_src_ip" {
  type = string
}