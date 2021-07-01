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
lifecycle{
  create_before_destroy = true
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
   
 resource "aws_route_table_association" "shan_public_association"{
   count =var.public_sn_count
   subnet_id = aws_subnet.shan_public_subnet.*.id[count.index]
   route_table_id = aws_route_table.shan_public_rt.id
 }
    
    
 resource "aws_internet_gateway" "shan_internet_gateway" {
    vpc_id = aws_vpc.shan_vpc.id
    
    tags = {
      Name = "shan_igw"
    
    }
  
} 

 resource "aws_route_table"  "shan_public_rt"
       vpc_id = aws_vpc.shan_vpc.id
    
    tags = {
      Name = "shan_public"
    
    }
  
} 
  
 resource "aws_route"  "default_route"
     route_table_id = aws_route_table.shan_public_rt.id
     destination_cidr_block = "0.0.0.0./0"
     gateway_id = aws_internet_gateway.shan_internet_gateway.id
    
   
     }
  
} 

resource "aws_default_route_table" "shan_private_rt" {
  default_route_table_id =aws_vpc_shan_vpc.default_route_table.id
  
  tags ={
    Name = "shan_private"
  }

}
    
   
    

