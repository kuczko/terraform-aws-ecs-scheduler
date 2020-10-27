import json
import os
import boto3

def ecs_stop(clusterName,serviceName,desiredCount,AWSRegion):
    client = boto3.client('ecs')
    response = client.update_service(
    cluster=clusterName,
    service=serviceName,
    desiredCount=0)
    print(response)
    
def ecs_start(clusterName,serviceName,desiredCount,AWSRegion):
    client = boto3.client('ecs')
    response = client.update_service(
    cluster=clusterName,
    service=serviceName,
    desiredCount=desiredCount)
    print(response)
    
def lambda_handler(event, context):
    print('## EVENT')
    print(event)
    if event["action"] == "stop":
        print("Stopping...")
        ecs_stop(event["clusterName"],event["serviceName"],event["desiredCount"],event["AWSRegion"])
        
    if event["action"] == "start":
        print("Starting...")
        ecs_start(event["clusterName"],event["serviceName"],event["desiredCount"],event["AWSRegion"])
                
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

