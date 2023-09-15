# Expose VPC ID
output "vpc_id" {
  value = aws_vpc.new_vpc.id
}

# Expose Route Tables
output "public_rt" {
  value = aws_route_table.public_route.id
}


output "private_rt" {
  value = aws_route_table.private_route.id
}


## Public Subnet list
output "public_subnet_list" {
  value = aws_subnet.public_subnet.*.id
}


## Private Subnet list
output "private_subnet_list" {
  value = aws_subnet.private_subnet.*.id
}



## Public security_group list
output "public_security_group" {
  value = aws_security_group.public_access_sg.id
}


## Private security_group list
output "private_security_group" {
  value = aws_security_group.private_access_sg.id
}

/*
## EIP details
output "eip_allocation_id" {
  value = aws_eip.nat_public_ip.allocation_id
}
# #NAT GATEWAY details
output "aws_nat_gateway" {
  value = aws_nat_gateway.gateway_for_private_sn.id
}

*/