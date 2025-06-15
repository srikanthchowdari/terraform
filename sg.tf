data "aws_vpc" "default" {
  id = "vpc-0c610f84198d3342b"
}

resource "aws_security_group" "instance" {
  name = "web-instance-sg"
  vpc_id = data.aws_vpc.default.id
  description = "Allow inbound HTTP access"

  ingress {
    description = "Allow HTTP access on port 8080"
    from_port = var.server_port
    to_port   = var.server_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}