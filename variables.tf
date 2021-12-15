# VPC Variables
variable "vpc_cidr" {
    type = string
    default = "10.10.0.0/16"
    description = "CIDR block for the VPC"
}

variable "public_subnet_count" {
    type = number
    default = 3
    description = "Number of Public Subnets for the VPC"
}

variable "private_subnet_count" {
    type = number
    default = 3
    description = "Number of Private Subnets for the VPC"
}


# Expressions used to calculate subnets
locals {
     total_subnet_count = var.public_subnet_count + var.private_subnet_count
     newbits_input = ceil(local.total_subnet_count / 2)
     public_subnet_cidrs = [for index in range(var.public_subnet_count):
                            cidrsubnet(var.vpc_cidr, local.newbits_input, index)]
     private_subnet_cidrs = [for index in range(var.private_subnet_count):
                            cidrsubnet(var.vpc_cidr, local.newbits_input, (index + var.public_subnet_count))]
}