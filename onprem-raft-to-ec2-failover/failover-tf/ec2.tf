data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    vault_cert    = file("${var.path_to_crt}")
    vault_ca      = file("${var.path_to_ca_crt}")
    vault_key     = file("${var.path_to_key}")
    api_addr      = var.vault_api_addr
    vault_snapshots_bucket     = var.vault_snapshots_bucket  # Added the bucket name to user_data
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "Policy to allow EC2 instance to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:ListBucket"        # Added ListBucket permission
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.vault_snapshots_bucket}"  # Allows listing the bucket itself
      },
      {
        Action   = "s3:GetObject"         # Allows getting objects from the bucket
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.vault_snapshots_bucket}/*"  # Allows access to all objects in the bucket
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
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

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

resource "tls_private_key" "vault_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vault_key" {
  key_name   = var.keypair_name
  public_key = tls_private_key.vault_key.public_key_openssh
}
