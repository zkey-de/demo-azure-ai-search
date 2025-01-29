#!/bin/bash

## Load environment variables
source .env

echo "Assign the role Search Service Contributor to the user ..."
if prompt_user; then 
az role assignment create \
    --assignee ${USER} \
    --role "Search Service Contributor" \
    --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Search/searchServices/${SERVICE_NAME}
fi

echo "Ensure both auth options are available (API Key, AAD) ..."
if prompt_user; then
az search service update \
    --name ${SERVICE_NAME} \
    --resource-group ${RESOURCE_GROUP} \
    --set authOptions="{\"aadOrApiKey\":{}}"    
fi
