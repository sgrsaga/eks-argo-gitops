### Network part
# Main Network resources
# 1.1. Create a VPC
# 1.2. Create a Internet Gateway
# 1.3. Create 2 Route tables
# 1.4. Create 3 Public Subnets in 3 AZs
# 1.5. Create 3 Private Subnets in 3 AZs - Not Required
# 1.6. Create Public access Security Group
# 1.7. Create Private Access Security Group - Not Required
# 1.8. Create EIP - Not Required
# 1.9. Create a NatGateway - Not Required

# Links between Network resources
# 2.1. Attach VPC to Internet Gateway
# 2.2. Link Internet Gate way to the Public Route table
# 2.3. Associate public Subnets to Public Route table
# 2.4. Link NateGateway to Private Route Table  - Not Required
# 2.5. Associate private subnets to the Private route tables - Not Required
# 2.6. Allow Inbound traffic from Public Security group to the Private Security group  - Not Required

# 1.1. Create a VPC
resource "aws_vpc" "new_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# 1.2. Create a Internet Gateway
# 2.1. Attach VPC to Internet Gateway
resource "aws_internet_gateway" "fargate_ig" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = var.ig_name
  }
}

# 1.3. Create 2 Route tables
# 2.2. Link Internet Gate way to the Public Route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fargate_ig.id
  }
  tags = {
    Name = var.public_rt
  }
}


resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = var.private_rt
  }
}


# 1.4. Create 3 Public Subnets
data "aws_availability_zones" "azs" {}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)
    cidr_block = var.public_subnets[count.index]
    vpc_id = aws_vpc.new_vpc.id
    availability_zone = element(data.aws_availability_zones.azs.names, count.index )
    map_public_ip_on_launch = true
    tags = {
      Name = "PUBLIC_SUBNET_${count.index}"
      Access = "PUBLIC"
    }
}

/* ## Not required
data "aws_subnet_ids" "public_subnets" {
  vpc_id = aws_vpc.new_vpc.id
}
*/

# 1.5. Create 3 Private Subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)
    cidr_block = var.private_subnets[count.index]
    vpc_id = aws_vpc.new_vpc.id
    availability_zone = element(data.aws_availability_zones.azs.names, count.index )
    tags = {
      Name = "PRIVATE_SUBNET_${count.index}"
      Access = "PRIVATE"
    }
}


# 2.3. Associate public Subnets to Public Route table
resource "aws_route_table_association" "public_rt_subnet_association" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  route_table_id = aws_route_table.public_route.id
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index )
}


# 2.5. Associate private subnets to the Private route tables
resource "aws_route_table_association" "private_rt_subnet_association" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  route_table_id = aws_route_table.private_route.id
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index )
}


# 1.6. Create Public access Security Group
resource "aws_security_group" "public_access_sg" {
  name = "PUBLIC_SG"
  vpc_id = aws_vpc.new_vpc.id
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "PUBLIC_SG"
  }
}

# Add Ingress Rules to Public Security Group
resource "aws_security_group_rule" "public_sg_ingress_rules" {
  count = length(var.public_access_sg_ingress_rules)
  from_port = var.public_access_sg_ingress_rules[count.index].from_port
  protocol = var.public_access_sg_ingress_rules[count.index].protocol
  security_group_id = aws_security_group.public_access_sg.id
  to_port = var.public_access_sg_ingress_rules[count.index].to_port
  type = "ingress"
  cidr_blocks = var.public_source_cidr
  ipv6_cidr_blocks = var.public_source_cidr_v6
}


# 1.7. Create Private Access Security Group  - only from Public Security group allowed
# 2.6. Allow Inbound traffic from Public Security group to the Private Security group
resource "aws_security_group" "private_access_sg" {
  name = "PRIVATE_SG"
  vpc_id = aws_vpc.new_vpc.id
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    security_groups = [ aws_security_group.public_access_sg.id]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "PRIVATE_SG"
  }
}


# 1.8. Create EIP
resource "aws_eip" "nat_public_ip" {
  vpc = true
}

# 1.9. Create a NatGateway and link a public subnet
resource "aws_nat_gateway" "gateway_for_private_sn" {
  allocation_id = aws_eip.nat_public_ip.id
  subnet_id = element(aws_subnet.public_subnet.*.id, 0 )
  depends_on = [aws_eip.nat_public_ip, aws_subnet.public_subnet]
  tags = {
    Name = "NAT-GW-PUBLIC-ACCESS"
  }
}



# 2.4. Link NateGateway to Private Route Table
resource "aws_route" "link_nat_gateway" {
  route_table_id = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gateway_for_private_sn.id
  depends_on = [aws_eip.nat_public_ip,aws_route_table.private_route, aws_subnet.public_subnet]
}

