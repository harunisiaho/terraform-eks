variable "basic_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "aws_availability_zones" {
    description = "A list of availability zones in which tio create subnets"
    type = list(string) 
    default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "vpc_name" {
  type = string
  default = "main-vpc"
}

variable "igw_name" {
  type = string
  default = "main-igw"
}

variable "nat_gw_name" {
  type = string
  default = "main-nat-gw"
}