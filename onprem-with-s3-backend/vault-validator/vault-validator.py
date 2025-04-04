import requests
import time
import sys
import os

import hvac

from heartbeat import send_heartbeat

TOKEN = os.getenv('VAULT_DEV_TOKEN')
VAULT_INSTANCE = os.getenv('VAULT_INSTANCE', 'https://localhost:8200')

vault_validators = {"can_read_secret": True,
                    "can_access_url": True, # Work on function
                    
                    }
client = hvac.Client(
    url=VAULT_INSTANCE,
    token=TOKEN,
    verify=False #if instance is TLS, decide whether to verify or not when sending requests
)


#Need to add additional validators, secret reading alone isn't a good validator on whether a vault instance is up and running or not.
def can_read_secret():
    try:
        read_response = client.secrets.kv.read_secret_version(path='vault-validator', mount_point="dev-secrets")
        vault_running = read_response['data']['data']['VaultIsRunning']
        print(f'Vault has returned the secret value : {vault_running}')
        vault_validators.update({'can_read_secret': True})
    except Exception as e :
        print(f'{e} Cannot return secret, vault instance might be offline! ,can_read_secret validator failed!')
        vault_validators.update({'can_read_secret': False})


def report_onprem_vault_connection_status():
    
    if all(vault_validators.values()):
        print('reporting to cloudwatch that vault is running!')
        send_heartbeat(metric_name='VaultIsRunning',
                                 metricNamespace='Custom/VaultHeartbeat',
                                 metric_value=1)
    else:
        print('reporting to cloudwatch that vault isn\'t running!')
        send_heartbeat(metric_name='VaultIsRunning',
                                 metricNamespace='Custom/VaultHeartbeat',
                                 metric_value=0)
        
def main():
    can_read_secret()
    while True:
        can_read_secret()
        report_onprem_vault_connection_status()
        time.sleep(20)
        
main()