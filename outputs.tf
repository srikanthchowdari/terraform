output "web_server_public_ip" {
  value = aws_lb.alb.dns_name
  description = "the domain name of the load balancer"
}