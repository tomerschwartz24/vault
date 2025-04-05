variable "ami" {
    type = string
    description = "AMI of the image."
    default = "ami-0ecf75a98fe8519d7"
}

variable "instance_type" {
    type = string
    description = "type of instance."
    default = "t3.micro"
  
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

variable "vault_api_addr" {
  type = string
  description = "the ip address of the vault instance ( should match the domain provided during certs creation; e.g - https://vault.mydomain.com:8200)"
}
variable "path_to_crt" {
    type = string
    description = "path to crt file (vault.crt) (must be pre-existing)"
    
}

variable "path_to_key" {
    type = string
    description = "path to key file (vault.key) (must be pre-existing)"
    
}

variable "path_to_ca_crt" {
    type = string
    description = "path to ca-crt file (vault-ca.crt) (must be pre-existing)"
    
}

variable "vault_snapshots_bucket" {
    type = string
    description = "the bucket name that stores the backup snapshots of vault raft cluster"
  
}