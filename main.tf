terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-1"
}


module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "eks-vpc-01"
    cidr = "10.122.0.0/16"

    azs = ["us-west-1a", "us-west-1b"]

    private_subnets = ["10.122.1.0/24","10.122.2.0/24"]
    public_subnets =  ["10.122.4.0/24","10.122.5.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    enable_dns_support   = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-eks-cluster-01"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  control_plane_subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.xlarge", "m5.xlarge", "m5n.xlarge", "m5zn.xlarge"]
  }

  eks_managed_node_groups = {
    node-group-01 = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  authentication_mode = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    console_user = {
      principal_arn     = "arn:aws:iam::558111126607:user/isiaho.admin"

      policy_associations = {
        policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Name = "eks-cluster-01"
  }
}

resource "aws_eks_fargate_profile" "dev" {
  fargate_profile_name      = "dev"
  cluster_name              = module.eks.cluster_name
  pod_execution_role_arn    = "arn:aws:iam::558111126607:role/AmazonEKSFargatePodExecutionRole"
  subnet_ids                = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  selector {
    namespace = "dev"
    labels = {
      app = "fargate-app"
    }
  }
}

# resource "aws_eks_fargate_profile" "coredns" {
#   fargate_profile_name      = "coredns"
#   cluster_name              = module.eks.cluster_name
#   pod_execution_role_arn    = "arn:aws:iam::558111126607:role/AmazonEKSFargatePodExecutionRole"
#   subnet_ids                = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

#   selector {
#     namespace = "kube-system"
#     labels = {
#       k8s-app = "kube-dns"
#     }
#   }
# }

module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = "eks-efs"
  encrypted      = true

  # Mount targets / security group
  mount_targets = {
    "us-west-1a" = {
      subnet_id = module.vpc.private_subnets[0]
    }
     "us-west-1b"= {
      subnet_id = module.vpc.private_subnets[1]
    }
  }

  security_group_description = "Example EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name = "eks-efs"
  }
}

resource "aws_eks_addon" "aws-efs-csi-driver" {
  cluster_name =module.eks.cluster_name
  addon_name   = "aws-efs-csi-driver"
}

