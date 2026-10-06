terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0" # the terraform binary itself
}
provider "aws" {
  region = var.aws_region
  # No profile/credentials block needed
  # EC2 Instance Role supplies auth automatically
  default_tags {
    tags = {
      Course    = "CIS-4641"
      ManagedBy = "terraform"
    }
  }
}
