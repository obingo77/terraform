terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

#configure aws Provider

provider "aws" {
    region = vars.aws_region
}