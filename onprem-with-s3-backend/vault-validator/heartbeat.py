import boto3
import os
import boto3.session


session = boto3.Session(
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    region_name=os.getenv("AWS_DEFAULT_REGION", "eu-central-1")
)

cloudwatch = session.client('cloudwatch')

def send_heartbeat(metric_name, metric_value, metricNamespace='Custom/VaultHeartbeat'):
    cloudwatch.put_metric_data(
        Namespace=metricNamespace,
        MetricData=[
            {
                'MetricName': f'{metric_name}',
                'Value': metric_value,
                'Unit': 'Count'
            }
        ]
    )
