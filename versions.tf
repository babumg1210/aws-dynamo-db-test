terraform {
  required_version = ">= 1.6"  # Ensures you're using a version >= 1.6 of Terraform
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"  # Ensure using AWS provider version 5.0 or above
    }
  }

  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "mytestapplication1234"  # Make sure this S3 bucket exists in your account
    key    = "terraform.tfstate"      # The state file name
    region = "us-east-1"              # The region where the S3 bucket is located
  }
}
