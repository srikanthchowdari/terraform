output "web_server_public_ip" {
  value = aws_instance.this.public_ip
  description = "web server public ip"
}