#-----networking-----

resource "random_pet" "name" {}

resource "aws_vpc" "shan_vpc" {
  cidr_block = var.vpc_cdr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "shan_vpc-${random_pet.name.id}"
  }
}

resource "aws_subnet" "shan_public_subnet" {
  count = length(var.public_cdrs)
  vpc_id = aws_vpc.shan_vpc.id
  cidr_block = var.public_cdrs[count.index]
  map_public_ip_on_launch = true
  availabity_zone =[count.index]
  
  tags ={
    Name = "shan_public_$(count.index + 1)"
  }
