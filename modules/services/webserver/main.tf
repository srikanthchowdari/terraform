# resource "aws_instance" "this" {
#   ami           = "ami-021d9f8e43481e7da"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [ aws_security_group.instance.id ]

#   user_data = templatefile("user-data.sh", {
#     server_port = var.server_port
#     db_address = data.terraform_remote_state.db.outputs.address
#     db_port = data.terraform_remote_state.db.outputs.port
#   })
#   user_data_replace_on_change = true
#   tags = {
#     name = "base-web-server"
#   }
# }


resource "aws_security_group" "asg" {
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

resource "aws_launch_template" "asg" {
  image_id = "ami-021d9f8e43481e7da"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.asg.id]

  user_data = base64encode(templatefile("user-data.sh", {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  }))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  launch_template {
    id = aws_launch_template.asg.id
  }
  min_size = 2
  max_size = 10

  tag {
    key = "anme"
    value = "terraform-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "alb" {
  name = "terraform-asg-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_listener_rule" "alb" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "alb-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}