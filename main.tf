locals {
  region = "ap-northeast-1" # Japan
  tags = {
    Developer = "Henry Chou"
  }
}

terraform {
  # terraform version
  required_version = "~> 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-qapp"
    key    = "dev.tfstate"
    region = "ap-northeast-1" # Japan
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
