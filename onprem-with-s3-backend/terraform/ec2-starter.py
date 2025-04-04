import boto3
import os
region = 'eu-central-1'

INSTANCE_NAME = os.getenv("INSTANCE_NAME")

ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    response = ec2.describe_instances(
        Filters=[{'Name': 'tag:Name', 'Values': [INSTANCE_NAME]}]
    )
    
    instances = [i['InstanceId'] for r in response['Reservations'] for i in r['Instances']]
    
    if not instances:
        print(f"No instances found with name {INSTANCE_NAME}")
        return
    
    ec2.start_instances(InstanceIds=instances)
    print(f"Starting EC2 instances: {instances}")
