terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  # Task 2. Partial config on purpose — bucket name stays out of the module.
  # init with: terraform init -backend-config=backend.hcl
  # Bootstrap the bucket and the lock table first (task2-backend/bootstrap).
  backend "s3" {}
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "terraform"
      Repo        = "arrise-devops-assignment"
    }
  }
}
