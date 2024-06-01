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

terraform {
  backend "s3" {
    region         = "us-west-1"
    bucket         = "clevertap-terraform-infra"
    key            = "state.tfstate"
    dynamodb_table = "clevertap-terraform-locks"
    encrypt        = true
  }
}


