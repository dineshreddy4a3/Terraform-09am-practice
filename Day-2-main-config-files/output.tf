output "publicip" {
  value = aws_instance.dev.private_ip

}
output "private_ip" {
  value = aws_instance.dev.public_ip

}