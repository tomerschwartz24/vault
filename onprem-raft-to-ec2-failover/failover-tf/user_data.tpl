#cloud-config
package_update: true
package_upgrade: true
packages:
  - yum-utils
  - shadow-utils
  - aws-cli

write_files:
  - path: /etc/vault.d/vault.crt
    permissions: '0644'
    content: |
      ${indent(6, vault_cert)}

  - path: /etc/vault.d/vault.key
    permissions: '0644'
    content: |
      ${indent(6, vault_key)}

  - path: /etc/vault.d/vault.ca
    permissions: '0644'
    content: |
      ${indent(6, vault_ca)}

runcmd:
  - yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  - yum -y install vault
  - mkdir -p /etc/vault.d

  - |
    cat <<EOF | sudo tee /etc/vault.d/vault.hcl
    listener "tcp" {
      address     = "0.0.0.0:8200"
      tls_disable = false
      tls_client_ca_file = "/etc/vault.d/vault-ca.crt"
      tls_cert_file = "/etc/vault.d/vault.crt"
      tls_key_file  = "/etc/vault.d/vault.key"
    }
    disable_mlock = true

    storage "raft" {
      path    = "/var/lib/vault"
      node_id = "vault-1"
    }

    api_addr = "${api_addr}"
    cluster_addr = "http://127.0.0.1:8201"

    ui = true
    EOF

  - |
    cat <<EOF | sudo tee /etc/systemd/system/vault.service
    [Unit]
    Description="HashiCorp Vault"
    Documentation="https://developer.hashicorp.com/vault/docs"
    ConditionFileNotEmpty="/etc/vault.d/vault.hcl"

    [Service]
    User=vault
    Group=vault
    SecureBits=keep-caps
    AmbientCapabilities=CAP_IPC_LOCK
    CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
    NoNewPrivileges=yes
    ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
    ExecReload=/bin/kill --signal HUP
    KillMode=process
    KillSignal=SIGINT

    [Install]
    WantedBy=multi-user.target
    EOF

  - mkdir -p /var/lib/vault
  - chown -R vault:vault /var/lib/vault
  - chmod -R 750 /var/lib/vault

  - systemctl daemon-reload
  - systemctl enable vault
  - systemctl start vault
  - systemctl status vault