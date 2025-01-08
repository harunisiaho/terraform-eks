module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
  }

  vpc_id                   = module.eks_vpc.vpc_id
  subnet_ids               = module.eks_vpc.private_subnets
  control_plane_subnet_ids = module.eks_vpc.public_subnets
  

   eks_managed_node_groups = {
    node-group-01 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.large"]

      min_size     = 0
      max_size     = 3
      desired_size = 3
      iam_role_additional_policies = {
          ssm_policy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          ebs_csi_policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
          lbc_policy = "arn:aws:iam::${var.aws_account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
          external_dns_policy = "arn:aws:iam::${var.aws_account_id}:policy/AllowExternalDNSUpdates"
          amazon_eks_workernode_policy= "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        }
   
      
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    access_entry_01 = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${var.aws_account_id}:role/AmazonSSMRoleForInstancesQuickSetup"
      policy_associations = {
        admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    },
    access_entry_02 = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${var.aws_account_id}:role/admin"
      policy_associations = {
        admin_policy = {
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
  }
}

resource "aws_eks_access_entry" "allow" {
  cluster_name      = module.eks_cluster.cluster_name
  principal_arn     = "arn:aws:iam::${var.aws_account_id}:user/harun"
  kubernetes_groups = ["masters"]
  type              = "STANDARD"
}