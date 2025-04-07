#cloud-config
package_update: true
package_upgrade: true
packages:
  - yum-utils
  - shadow-utils
  - aws-cli
  - jq

write_files:
  - path: /etc/vault.d/vault.crt
    permissions: '0644'
    content: |
      ${indent(6, vault_tls_crt)}

  - path: /etc/vault.d/vault.key
    permissions: '0644'
    content: |
      ${indent(6, vault_tls_key)}


  - path: /tmp/vault-restore.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      export VAULT_CACERT="/etc/vault.d/vault.crt"
      KEY_THRESHOLD=2
      INIT_FILE="/tmp/init_keys.json"
      echo "Initalizing vault for the first time"
      vault operator init -key-shares=3 -key-threshold=$KEY_THRESHOLD -format=json > $INIT_FILE


      echo "Unsealing Vault..."
      for key in $(jq -r ".unseal_keys_b64[:$KEY_THRESHOLD][]" "$INIT_FILE"); do
          vault operator unseal "$key"
      done

      ROOT_TOKEN=$(jq -r ".root_token" "$INIT_FILE")
      vault login token=$ROOT_TOKEN
      echo "Restoring production raft snapshot!"
      vault operator raft snapshot restore --force /tmp/vault_raft_*.snap
#At this point the vault is resealed and the key threshold for unseal is  is 0/3 like the original prod cluster

runcmd: 
  - latest_snapshot=$(aws s3 ls s3://${vault_snapshots_bucket}/  --recursive | sort | tail -n 1 | awk '{print $4}')
  - aws s3 cp s3://${vault_snapshots_bucket}/$latest_snapshot /tmp
  - yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  - yum -y install vault
  - mkdir -p /etc/vault.d

  - chown vault:vault /etc/vault.d/vault.key /etc/vault.d/vault.crt
  - |
    cat <<EOF | sudo tee /etc/vault.d/vault.hcl
    listener "tcp" {
      address     = "0.0.0.0:8200"
      tls_disable = false
      tls_client_ca_file = "/etc/vault.d/vault.crt"
      tls_cert_file = "/etc/vault.d/vault.crt"
      tls_key_file  = "/etc/vault.d/vault.key"
    }
    disable_mlock = true

    storage "raft" {
      path    = "/var/lib/vault"
      node_id = "failover-vault"
    }

    api_addr = "https://${vault_api_addr}:8200"
    cluster_addr = "https://127.0.0.1:8201"

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
    Enviornment=VAULT_CACERT="/etc/vault.d/vault.crt"
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
  - sleep 20
  - /tmp/vault-restore.sh