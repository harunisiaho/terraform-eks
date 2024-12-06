variable "alb_name" {
  type = string
  default = "alb"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)  
}

variable "alb_logs_bucket_name" {
  type = string
}

