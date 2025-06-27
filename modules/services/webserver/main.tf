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
  name = "${var.cluster_name}-sg"
  vpc_id = data.aws_vpc.default.id
  description = "Allow inbound HTTP access"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.asg.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb-sg"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_launch_template" "asg" {
  image_id = "ami-021d9f8e43481e7da"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.asg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
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
  min_size = var.min_size
  max_size = var.max_size

  tag {
    key = "anme"
    value = "${var.cluster_name}-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "alb" {
  name = "${var.cluster_name}-asg-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = local.http_port
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
  name     = "${var.cluster_name}-alb-target-group"
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