resource "aws_instance" "vault" {
  ami           = var.ami
  instance_type = var.instance_type
  user_data = file("user_data.yaml")
  key_name = aws_key_pair.vault_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.outbound_all.id]

  
  tags = {
    Name = var.instance_name
  }

}


resource "tls_private_key" "vault_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vault_key" {
  key_name   = var.keypair_name
  public_key = tls_private_key.vault_key.public_key_openssh
}
