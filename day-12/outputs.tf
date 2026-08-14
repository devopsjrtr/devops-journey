output "web_sunucu_ip" {
  description = "Nginx sunucusunun public IP adresi"
  value       = aws_instance.web_sunucum.public_ip
}
