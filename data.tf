data "aws_vpc" "default" {
  id = "vpc-0c610f84198d3342b"
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}