resource "aws_instance" "vault" {
  ami           = "ami-07eef52105e8a2059" 
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.vault_profile.name
  security_groups = [aws_security_group.vault_sg.name]
   key_name             = "vault-key"
  
  user_data = file("${path.module}/cloud-init.yaml")

  tags = {
    Name = "vault"
  }
}
