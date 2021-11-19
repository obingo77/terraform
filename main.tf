provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  name_suffix = "${var.project_name}-${var.environment}"
}

locals {
  required_tags = {
    project     = var.project_name,
    environment = var.environment
  }
  tags = merge(var.resource_tags, local.required_tags)
}

# --vpc module--
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name            = "vpc-${local.name_suffix}"
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)

  enable_vpn_gateway = var.enable_vpn_gateway
  enable_nat_gateway = false
}


module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.17.0"

  name        = "web-sg-${local.name_suffix}"
  description = "security group for web-servers with  HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  //  ingress_cidr_blocks = module.vpc.public_subnet_cidr_blocks

  tags = local.tags

}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.17.0"

  name                = "lb-sg-${local.name_suffix}"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags                = local.tags

}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}
module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.4.0"

  # Ensure load balancer name is unique
  name = "lb-${random_string.lb_id.result}-${local.name_suffix}"

  internal = false

  security_groups = [module.lb_security_group.this_security_group_id]
  subnets         = module.vpc.public_subnets

  //number_of_instances = length(aws_instances.app)
  //instances           = aws_instances.app.*.id

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }

  tags = local.tags

}

resource "aws_instance" "web" {
  count                       = 1
  ami                         = lookup(var.aws_amis, var.aws_region)
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnets[count.index % length(module.vpc.private_subnets)]
  vpc_security_group_ids      = [module.app_security_group.this_security_group_id]
  associate_public_ip_address = false
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y amazon-linux-extras
    sudo amazon-linux-extras enable httpd_modules
    sudo yum install httpd -y
      sudo systemctl enable httpd
   sudo systemctl start httpd
   echo "<html><body><div>This App was developed by Obingo77</div></html> > /var/www/html/index.html"
    EOF
}

