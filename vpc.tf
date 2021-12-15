# VPC Configuration

resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "Sandbox VPC"
    }
}

/*  Grabs a list of AWS Availability Zones which can be accessed by the AWS
    Account within the region configured in the provider. Avoids needing to
    manually add letters, or mistakes. (i.e. US-East-1 for the account doesn't
    have an AZ B and other Regions don't have 3 AZs available, such as
    US-West-1 and Ca-Central-1)
*/
data "aws_availability_zones" "available_in_region" {}


# Public Subnets

resource random_shuffle "nat_gw_subnet" {
    input = aws_subnet.public.*.id
    result_count = "1" # Only 1 NAT GW -- no redundancy for cost savings
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "Sandbox VPC IGW"
    }
}

resource "aws_nat_gateway" "this" {
    # Only 1 NAT GW -- no redundancy for cost savings
    allocation_id = aws_eip.nat_gw.id
    subnet_id = random_shuffle.nat_gw_subnet.result 

    tags = {
        Name = "Sandbox VPC NAT GW"
    }

    depends_on = [aws_internet_gateway.this]
}

resource "aws_eip" "nat_gw" {
    tags = {
        Name = "Sandbox VPC EIP for NAT GW"
    }
}

resource "aws_subnet" "public"{
    count = var.public_subnet_count

    vpc_id = aws_vpc.this.id
    cidr_block = local.public_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.available_in_region.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "Sandbox VPC Public Subnet ${count.index + 1}"
    }
}

resource "aws_route" "public_to_igw" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id

    depends_on = [aws_route_table.public, aws_internet_gateway.this]
    timeouts {
        create = "5m"
    }
}

resource "aws_route_table_association" "public" {
    count = var.public_subnet_count
    subnet_id = element(aws_subnet.public.*.id, count.index)
    route_table_id = aws_route_table.public.id
}


# Private Subnets

resource "aws_subnet" "private"{
    count = var.private_subnet_count
    vpc_id = aws_vpc.this.id
    cidr_block = local.private_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.available_in_region.names[count.index]
    map_public_ip_on_launch = false

    tags = {
        Name = "Sandbox VPC Private Subnet ${count.index}"
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id

    tags ={
        Name = "Sandbox VPC Private Route Table"
    }
}

resource "aws_route" "private_to_natgw" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id

    depends_on = [aws_route_table.private, aws_nat_gateway.this]
    timeouts {
        create = "5m"
    }
}

resource "aws_route_table_association" "private" {
    count = var.private_subnet_count
    subnet_id = element(aws_subnet.private.*.id, count.index)
    route_table_id = aws_route_table.private.id
}