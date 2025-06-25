terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.99.1"
    }
  }

  # backend "s3" {
  #   # Replace this with your bucket name!
  #   bucket         = "iam-tf-state-srich"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "eu-west-1"

  #   # Replace this with your DynamoDB table name!
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = "eu-west-1"
}