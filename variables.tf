variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "ebs_addon_version" {
  description = "EBS addon version"
  type        = string
  default     = "v1.34.0-eksbuild.1"
}

variable "vpc_cni_addon_version" {
  description = "VPC CNI addon version"
  type        = string
  default     = "v1.18.3-eksbuild.3"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster to create"
}

variable "allowed_account_ids" {
  type        = list(string)
  description = "The allowed AWS account ids"
  default     = []
}
