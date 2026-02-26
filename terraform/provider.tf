terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
   backend "s3" {
     bucket = "your-terraform-state-bucket"
     key    = "ecommerce/terraform.tfstate"
     region = "eu-west-1"
   }
}

provider "aws" {
  region = var.aws_region
}