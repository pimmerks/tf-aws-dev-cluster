# File contains cluster addons

# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_iam_policy" "vpc_cni_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.46.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

module "irsa-vpc-cni" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.46.0"

  allow_self_assume_role        = true
  create_role                   = true
  role_name                     = "AmazonEKSTFVPCCNIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.vpc_cni_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-node"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_addon_version
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  configuration_values     = jsonencode({
    "controller" = {
      # TODO: Change this when deploying a cluster with more then 1 node
      "replicaCount" = 1
    }
  })
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }

  timeouts {
    create = "1m"
    update = "1m"
    delete = "2m"
  }
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_addon_version
  service_account_role_arn = module.irsa-vpc-cni.iam_role_arn
  configuration_values     = jsonencode({
    "env" = {
      "ENABLE_PREFIX_DELEGATION" = "true"
      "WARM_PREFIX_TARGET" = "1"
    }
  })
  tags = {
    "eks_addon" = "vpc-cni"
    "terraform" = "true"
  }
  timeouts {
    create = "1m"
    update = "1m"
    delete = "2m"
  }
}
