module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    main = {
      name           = "${var.project_name}-ng"
      instance_types = [var.eks_node_instance_type]

      min_size     = var.eks_min_nodes
      max_size     = var.eks_max_nodes
      desired_size = var.eks_desired_nodes

      disk_size    = 50
      capacity_type = "ON_DEMAND"

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }
    }
  }
}