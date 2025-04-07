resource "aws_security_group" "ssh" {
  name        = "allow_ssh_from_office"
  description = "Allow ssh inbound traffic from your office"

  tags = {
    Name = "allow_ssh_from_office"
  }
}

resource "aws_security_group" "vault" {
  name        = "vault_port_access"
  description = "Allow access in vault port"

  tags = {
    Name = "vault_access"
  }
}
resource "aws_security_group" "outbound_all" {
  name        = "allow_outbound_traffic"
  description = "Allow egress traffic to everywhere"

  tags = {
    Name = "allow_outbound_all"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4         = var.vault_allow_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_security_group_rule" "allow_vault" {
  type              = "ingress"
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  cidr_blocks       = [var.vault_allow_cidr]
  security_group_id = aws_security_group.vault.id
}


resource "aws_vpc_security_group_egress_rule" "outbound_access" {
  security_group_id = aws_security_group.outbound_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" #same as "all ports"
}