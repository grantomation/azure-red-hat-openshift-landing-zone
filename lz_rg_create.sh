#!/bin/bash
export SUBSCRIPTION=$(az account show --query id -o tsv)
export LOCATION="<insert azure region where you would like to deploy resources>"
export HUB_RG="<insert name of the Hub Networking resource group>"
export SPOKE_RG="<insert name of spoke resource group containing ARO>"
export SERVICES_RG="<insert name of resource group containing services>"
export KEYVAULT_NAME="<insert desired name of keyvault. This needs to match value in 'action_params/keyvault.parameters.json>"
export SP_NAME="<insert the name of the Azure Service Principal (or app registration) that you created>"

az group create -n $HUB_RG -l $LOCATION
az group create -n $SPOKE_RG -l $LOCATION
az group create -n $SERVICES_RG -l $LOCATION

export APPID=$(az ad sp list --all --query "[?displayName == '$SP_NAME'].appId" -o tsv)

export SCOPE_HUB=$(az group create -n $HUB_RG -l $LOCATION --query id -o tsv)
export SCOPE_SPOKE=$(az group create -n $SPOKE_RG -l $LOCATION --query id -o tsv)
export SCOPE_SERVICES=$(az group create -n $SERVICES_RG -l $LOCATION --query id -o tsv)

az role assignment create --assignee $APPID --role contributor --scope $SCOPE_HUB &
az role assignment create --assignee $APPID --role contributor --scope $SCOPE_SPOKE & 
az role assignment create --assignee $APPID --role contributor --scope $SCOPE_SERVICES &
az role assignment create --assignee $APPID --role "User Access Administrator" --scope $SCOPE_SPOKE &
az role assignment create --assignee $APPID --role "User Access Administrator" --scope $SCOPE_HUB &
az role assignment create --assignee $APPID --role "User Access Administrator" --scope $SCOPE_SERVICES &

wait

az keyvault purge -n $KEYVAULT_NAME