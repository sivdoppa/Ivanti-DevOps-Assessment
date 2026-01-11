#!/bin/bash

# Create backend storage
RESOURCE_GROUP="tfstate-rg"
STORAGE_ACCOUNT="tfstatedevops$(date +%s)"
LOCATION="eastus"

az group create --name $RESOURCE_GROUP --location $LOCATION

az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY