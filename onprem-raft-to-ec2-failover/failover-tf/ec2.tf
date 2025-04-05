data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    vault_cert    = file("${var.path_to_crt}")
    vault_ca      = file("${var.path_to_ca_crt}")
    vault_key     = file("${var.path_to_key}")
    api_addr      = var.vault_api_addr
    vault_snapshots_bucket     = var.vault_snapshots_bucket
  }
}
resource "aws_instance" "vault" {
  ami                    = var.ami
  instance_type          = var.instance_type
  user_data              = data.template_file.user_data.rendered
  key_name               = aws_key_pair.vault_key.key_name
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.vault.id,
    aws_security_group.outbound_all.id
  ]
  iam_instance_profile    = aws_iam_instance_profile.ec2_s3_profile.name 

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
