module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                  = "myApp-eks-cluster"  
  cluster_version               = "1.24"
  cluster_endpoint_public_access = true

  subnet_ids = module.myApp-vpc.private_subnets
  vpc_id     = module.myApp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t2.small"]
      key_name         = "public-kp"
    }
  }
}
