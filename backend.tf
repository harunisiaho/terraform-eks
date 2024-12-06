terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
    backend "s3" {
        bucket = "terraform-state-isiaho"
        key    = "jenkins/terraform.tfstate"
        region = "us-east-2"
    }
}