terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.98.0"
    }
  }

#   backend "s3" {
#     bucket = "iam-tf-state-srich"
#     key = "envs/dev/terraform.tfstate"
#     region = "eu-west-1"
#     encrypt = true
#     dynamodb_table = "terraform-locks"
#   }
}

provider "aws" {
  region = "eu-west-1"
}