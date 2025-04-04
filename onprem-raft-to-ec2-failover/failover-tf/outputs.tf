
output "private_key_pem" {
  value     = tls_private_key.vault_key.private_key_pem
  sensitive = true
}

output "public_ip" {
    value = aws_instance.vault.public_ip
  
}