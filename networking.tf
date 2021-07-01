#-----networking-----

data "aws_availability_zones" "available" {}

resource "random_pet" "name" {}

resource "random_shuffle" "az_list" {
  input = aws_availability_zones.available.names
  result_count = var.max_subnets
}



resource "aws_vpc" "shan_vpc" {
  cidr_block = var.vpc_cdr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "shan_vpc-${random_pet.name.id}"
  }
}

resource "aws_subnet" "shan_public_subnet" {
  count = var.public_sn_count
  vpc_id = aws_vpc.shan_vpc.id
  cidr_block = var.public_cdrs[count.index]
  map_public_ip_on_launch = true
  availabity_zone = random_shuffle.az_list[count.index]
  
  tags ={
    Name = "shan_public_$(count.index + 1)"
  }
  
  resource "aws_subnet" "shan_private_subnet" {
  count = var.private_sn_count
  vpc_id = aws_vpc.shan_vpc.id
  cidr_block = var.private_cdrs[count.index]
  map_public_ip_on_launch false
  availabity_zone = random_shuffle.az_list[count.index]
  
  tags ={
    Name = "shan_private_$(count.index + 1)"
  }
