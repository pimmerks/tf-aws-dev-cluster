terraform {
  cloud {
    # export TF_CLOUD_ORGANIZATION="..."
    # export TF_WORKSPACE="..."
    workspaces {
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.67.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }
  }

  required_version = "~> 1.3"
}

provider "aws" {
  region              = var.region
  allowed_account_ids = var.allowed_account_ids
}
