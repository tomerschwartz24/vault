variable "ami" {
    type = string
    description = "AMI of the image."  
}

variable "instance_type" {
    type = string
    description = "type of instance."
  
}

variable "instance_name" {
    type = string
    default = "failover-prod-vault"
    description = "name of the failover instance"
  
}

variable "ssh_sg_ingress_cidr" {
    type = string
    description = "cidr to allow access for into the vault instance via SSH (set it to your office network)"
}

variable "keypair_name" {
    type = string
    default = "vault_failover_key"
    description = "the keypair name to access the vault instance."
  
}