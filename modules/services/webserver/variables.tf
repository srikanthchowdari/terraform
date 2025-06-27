variable "server_port" {
  description = "server port"
  type = number
  default = 8080
}

variable "cluster_name" {
  description = "name of webserver cluster"
  type = string
}

variable "db_remote_state_bucket" {
  description = "the name of the s3 bucket for databases remote "
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}