terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }
  }

  required_version = ">= 1.1"
}

provider "aws" {
  region = "us-west-1"
}


