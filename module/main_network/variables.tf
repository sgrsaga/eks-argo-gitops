# 1.1. Create a VPC
variable "vpc_name" {
  type = string
}
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "public_source_cidr" {
  type = list(string)
  default = ["10.0.0.0/16"]
}
variable "public_source_cidr_v6" {
  type = list(string)
  default = ["::/0"]
}


# 2. Create a Internet Gateway
variable "ig_name" {
  type = string
}

# 1.3. Create 2 Route tables
variable "public_rt" {
  type = string
  default = "Public_RT"
}
variable "private_rt" {
  type = string
  default = "Private_RT"
}

# 1.4. Create Public Subnets
variable "public_subnets" {
  type = list(string)
  default = ["10.0.1.0/24"]
}

# 1.5. Create Private Subnets
variable "private_subnets" {
  type = list(string)
  default = ["10.0.2.0/24"]
}

# 1.6. Create Public access Security Group
variable "public_access_sg_ingress_rules" {
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
  }))
  default = [
    {
      protocol = "tcp"
      from_port = 443
      to_port = 443
    }
  ]
}
