terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tls = {
      source = "hashicorp/tls"
    }

    local = {
      source = "hashicorp/local"
    }
  }
}

provider "aws" {
  region = var.aws_region
}