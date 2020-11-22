# variables may not be used here
terraform {
  backend "s3" {
    bucket         = "tdk-terraform-state-awssec.io-mwa"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-awssec-mwa"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.11.0"
    }
  }
}

provider "aws" {
  region = var.region
}
