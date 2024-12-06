variable "aws_region" {
  type = string
  default = "eu-west-1"
}

variable "basic_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "aws_availability_zones" {
    description = "A list of availability zones in which tio create subnets"
    type = list(string) 
    default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_name" {
  type = string
  default = "eks-vpc"
}

variable "igw_name" {
  type = string
  default = "eks-igw"
}

variable "nat_gw_name" {
  type = string
  default = "eks-nat-gw"
}

variable "instance_type" {
  type = string
  default = "t3.xlarge"
  
}

variable "alb_name" {
  type = string
  default = "eks-alb"  
}

variable "alb_tg_name" {
  type = string
  default = "eks-alb-tg"

}

variable "alb_logs_bucket_name" {
  type = string
  
}

variable "elb_account_id" {
  type = string
  default = "033677994240"
}

variable "aws_account_id" {
  type = string  
}

variable "eks_cluster_name" {
  type = string
  default = "eks-cluster-01"
  
}

variable "instance_profile" {
  type = string
  default = "AmazonSSMRoleForInstancesQuickSetup"
  
}
