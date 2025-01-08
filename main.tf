provider "aws" {
  region = var.aws_region
}

module "eks_vpc" {
  source = "./modules/vpc"
  basic_cidr_block = var.basic_cidr_block
  aws_availability_zones = var.aws_availability_zones
  vpc_name = var.vpc_name
  igw_name = var.igw_name
  nat_gw_name = var.nat_gw_name
}

resource "aws_iam_role" "pod_execution_role" {
    name = "pod_execution_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "eks-fargate-pods.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "attch_pod_execution_role_policy" {
    role = aws_iam_role.pod_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

resource "aws_eks_fargate_profile" "fargate_profile" {
    cluster_name = var.eks_cluster_name
    fargate_profile_name = "fargate_profile"
    pod_execution_role_arn = aws_iam_role.pod_execution_role.arn
    subnet_ids = module.eks_vpc.private_subnets
    tags = {
        Name = "fargate_profile"
    }
    depends_on = [kubernetes_namespace.fargate]
    selector {
        namespace = "fargate"
    }
}


resource "aws_iam_role" "pod_identity_role" {
    name = "PodIdentityRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "pods.eks.amazonaws.com"
                },
                "Action": [
                    "sts:AssumeRole",
                    "sts:TagSession"
            ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "attach_pod_identity_policy" {
    role = aws_iam_role.pod_identity_role.name
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_eks_pod_identity_association" "pod_identity_association" {
  cluster_name    = module.eks_cluster.cluster_name
  namespace       = "pod-identity"
  service_account = "eks-pod-identity"
  role_arn        = aws_iam_role.pod_identity_role.arn
}