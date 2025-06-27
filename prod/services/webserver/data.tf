data "aws_vpc" "default" {
  id = "vpc-0c610f84198d3342b"
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "iam-tf-state-srich"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "eu-west-1"
  }
}