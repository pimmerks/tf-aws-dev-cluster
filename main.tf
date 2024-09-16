# Filter out local zones, which are not currently supported
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = "${var.cluster_name}-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.1"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  # disable logging to cloudwatch
  cluster_enabled_log_types = []

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
    # so we need to disable it to use the default template provided by the AWS EKS managed node group service
    use_custom_launch_template = true
    create_launch_template     = true

    # Allow more pods per node
    # bootstrap_extra_args = "--use-max-pods false --kubelet-extra-args '--max-pods=110' --cni-prefix-delegation-enabled"
    bootstrap_extra_args = "--use-max-pods false --kubelet-extra-args '--max-pods=110'"
  }

  eks_managed_node_groups = {
    main = {
      launch_template_name = "${var.cluster_name}-main-on-demand"
      name                 = "on-demand"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }

    spot_only = {
      launch_template_name = "${var.cluster_name}-spot"
      name                 = "spot"

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      min_size     = 0
      max_size     = 5
      desired_size = 0
    }
  }
}
