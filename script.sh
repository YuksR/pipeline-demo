#!/bin/bash

# Define variables
TASK_DEFINITION_NAME="TASK-DEFINITION-NODEAPP"
REPOSITORY_URI="975050290535.dkr.ecr.us-east-1.amazonaws.com/nodejs:latest"
IMAGE_TAG="latest"
CLUSTER_NAME="node-cluster"
SERVICE_NAME="nodeapp-service-new"
DESIRED_COUNT=1

# Fetch existing task definition
task_definition=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION_NAME)

# Extract Role ARN, Family, and Container Name using jq
ROLE_ARN=$(echo $task_definition | jq -r '.taskDefinition.executionRoleArn')
FAMILY=$(echo $task_definition | jq -r '.taskDefinition.family')
CONTAINER_NAME=$(echo $task_definition | jq -r '.taskDefinition.containerDefinitions[0].name')

echo "Extracted Family: $FAMILY"
echo "Extracted Container Name: $CONTAINER_NAME"
echo "Extracted Role ARN: $ROLE_ARN"

# Register new task definition
new_task_definition=$(aws ecs register-task-definition \
    --family $FAMILY \
    --container-definitions "[{
        \"name\": \"$CONTAINER_NAME\",
        \"image\": \"$REPOSITORY_URI:$IMAGE_TAG\",
        \"essential\": true,
        \"portMappings\": [{
            \"containerPort\": 3000,
            \"hostPort\": 0
        }]
    }]" \
    --cpu "1024" \
    --memory "1024" \
    --network-mode "bridge" \
    --execution-role-arn $ROLE_ARN \
    --requires-compatibilities "EC2")

# Extract new task definition revision
NEW_REVISION=$(echo $new_task_definition | jq -r '.taskDefinition.revision')

echo "New Task Definition Revision: $NEW_REVISION"

# Update service to use the new task definition revision
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition "$FAMILY:$NEW_REVISION" \
    --desired-count $DESIRED_COUNT

echo "Service updated to use task definition $FAMILY:$NEW_REVISION"

 
}
