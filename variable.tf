
variable "aws_region" {
  default = "us-east-1"
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_cidr" {
  type = list(any)
}

variable "private_cidr" {
  type = list(any)
}

variable "public_sn_count" {
  type = number
}

variable "private_sn_count" {
  type = number
}

variable "max_subnets" {
  type = number
}
