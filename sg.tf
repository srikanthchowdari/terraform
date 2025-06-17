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

resource "aws_security_group" "alb" {
  name = "alb-sg"

  ingress {
    from_port = 80
    to_port   = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}