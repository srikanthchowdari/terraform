# output "web_server_public_ip" {
#   value = aws_lb.alb.dns_name
#   description = "the domain name of the load balancer"
# }

output "asg_name" {
  value = aws_autoscaling_group.asg.name
  description = "name of the auto scaling group"
}

output "alb_dns_name" {
  value = aws_lb.alb.name
  description = "the domain name of the load balancer"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the Security Group attached to the load balancer"
}

output "asg_security_group_id" {
  value       = aws_security_group.asg.id
  description = "The ID of the Security Group attached to the asg"
}