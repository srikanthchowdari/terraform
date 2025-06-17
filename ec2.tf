resource "aws_instance" "this" {
  ami           = "ami-021d9f8e43481e7da"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > ondex.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  user_data_replace_on_change = true
  tags = {
    name = "base-web-server"
  }
}