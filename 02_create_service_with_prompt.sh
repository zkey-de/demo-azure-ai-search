#!/bin/bash

## Load environment variables

source .env

## 1. Create resources

echo -e "\nCreate resource group ..."
if prompt_user; then
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

echo -e "\nCreate a search service..."
if prompt_user; then
    az search service create \
        --name $SERVICE_NAME \
        --resource-group $RESOURCE_GROUP \
        --sku $SEARCH_SKU \
        --location $LOCATION
fi

echo -e "\nCreate a storage account ..."
if prompt_user; then
    az storage account create \
        --name $STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --sku Standard_LRS
fi

echo -e "\nCreate a storage container..."
if prompt_user; then
    STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query [0].value -o tsv)
    az storage container create \
        --name $CONTAINER_NAME \
        --account-name $STORAGE_ACCOUNT_NAME \
        --account-key $STORAGE_KEY
fi

## 2. Prepare data

echo -e "\nDownload sample file and upload it to the storage container ..."
if prompt_user; then
    curl -o hotels.json $EXAMPLE_DATA_URL
    az storage blob upload \
        --account-name $STORAGE_ACCOUNT_NAME \
        --account-key $STORAGE_KEY \
        --container-name $CONTAINER_NAME \
        --file $EXAMPLE_DATA_FILENAME \
        --name $EXAMPLE_DATA_FILENAME \
        --overwrite
fi

echo -e "\nDownload sample index file and upload it to the storage container ..."
if prompt_user; then
    curl -o $EXAMPLE_DATA_INDEX_FILENAME $EXAMPLE_DATA_INDEX_URL
fi

## 3. Configure search service

echo -e "\nCreate Data Source using REST API and AAD Authentication..."
if prompt_user; then
    ACCESS_TOKEN=$(az account get-access-token --resource https://search.azure.com --query accessToken -o tsv)

    DATA_SOURCE_PAYLOAD=$(cat <<EOF
{
    "name": "${DATA_SOURCE_NAME}",
    "description": "Data source for hotel data",
    "type": "azureblob",
    "credentials": {
        "connectionString": "DefaultEndpointsProtocol=https;AccountName=$STORAGE_ACCOUNT_NAME;AccountKey=$STORAGE_KEY;EndpointSuffix=core.windows.net"
    },
    "container": {
        "name": "$CONTAINER_NAME"
    }
}
EOF
    )

    curl -X POST \
        "https://${SERVICE_NAME}.search.windows.net/datasources?api-version=${API_VERSION}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d "${DATA_SOURCE_PAYLOAD}"
fi

echo -e "\nCreate index ..."
if prompt_user; then
    curl -X POST \
      "https://${SERVICE_NAME}.search.windows.net/indexes?api-version=${API_VERSION}" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -d @hotels_index.json
fi

echo -e "\nCreate indexer ..."
if prompt_user; then
    curl -X POST \
      "https://${SERVICE_NAME}.search.windows.net/indexers?api-version=${API_VERSION}" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -d "{
        \"name\": \"${INDEXER_NAME}\",
        \"dataSourceName\": \"${DATA_SOURCE_NAME}\",
        \"targetIndexName\": \"${INDEX_NAME}\"
      }"
fi

echo -e "\nRun indexer ..."
if prompt_user; then
    curl -X POST \
      "https://${SERVICE_NAME}.search.windows.net/indexers/${INDEXER_NAME}/run?api-version=${API_VERSION}" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ACCESS_TOKEN"
fi

echo "Azure Search Service should be set up!"