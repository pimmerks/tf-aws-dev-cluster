variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "ebs_addon_version" {
  description = "EBS addon version"
  type        = string
  default     = "v1.26.0-eksbuild.1"
}
