terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.69.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  shared_credentials_files = ["C:/Users/hprav/.aws/credentials"]
  profile = "terraform-node-js"
}