output "output_tvpc_id" {
    value = aws_vpc.vpc.id
}

data "aws_subnet" "private_a" {
    filter {
        name = "tag:Name"
        values = ["*private-a"] 
    }
}
data "aws_subnet" "private_b" {
    filter {
        name = "tag:Name"
        values = ["*private-b"] 
    }
}
output "output_private_a_subnet_id" {
    value = data.aws_subnet.private_a.id
}
output "output_private_b_subnet_id" {
    value = data.aws_subnet.private_b.id
}
output "output_gw1_gre_src_ip" {
    value = aws_network_interface.private_nics-a.private_ip 
}
output "output_gw2_gre_src_ip" {
    value = aws_network_interface.private_nics-b.private_ip 
}