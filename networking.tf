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
