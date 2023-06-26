#!/bin/bash

source helper_vars.sh

az group create -n $HUB_RG -l $LOCATION
az group create -n $SPOKE_RG -l $LOCATION
az group create -n $SERVICES_RG -l $LOCATION

export APPID=$(az ad sp list --all --query "[?displayName == '$SP_NAME'].appId" -o tsv)

export SCOPE_HUB=$(az group create -n $HUB_RG -l $LOCATION --query id -o tsv)
export SCOPE_SPOKE=$(az group create -n $SPOKE_RG -l $LOCATION --query id -o tsv)
export SCOPE_SERVICES=$(az group create -n $SERVICES_RG -l $LOCATION --query id -o tsv)

# Create Resource Groups then Assign and Scope Contributor and User Access Administrator Permissions
az role assignment create --assignee $APPID --role contributor --scope $SCOPE_HUB &
az role assignment create --assignee $APPID --role contributor --scope $SCOPE_SPOKE & 
az role assignment create --assignee $APPID --role contributor --scope $SCOPE_SERVICES &
az role assignment create --assignee $APPID --role "User Access Administrator" --scope $SCOPE_SPOKE &
az role assignment create --assignee $APPID --role "User Access Administrator" --scope $SCOPE_SERVICES &

# Configure and set permissions for group claim on the AAD App Registration/Service Principal
az rest --method PATCH --url $GRAPH_URL --headers Content-Type=application/json --body '{"web":{"redirectUris":["'$REDIRECT_URL'"]}}' &
az ad app update --id $AAD_APP_REG_OBJECT_ID --set optionalClaims='{"idToken": [{"name": "email","essential": false,"additionalProperties": []}, {"name": "preferred_username","essential": false,"additionalProperties": []}, {"name": "groups","source": "groups","essential": false}], "accessToken": [{"name": "groups","source": "groups","essential": false}]}' &
az ad app update --id $AAD_APP_REG_OBJECT_ID --set groupMembershipClaims=SecurityGroup &
az ad app permission add --id $AAD_APP_REG_OBJECT_ID --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope &
az ad app permission add --id $AAD_APP_REG_OBJECT_ID --api 00000003-0000-0000-c000-000000000000 --api-permissions 64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0=Scope &

wait

az keyvault purge -n $KEYVAULT_NAME