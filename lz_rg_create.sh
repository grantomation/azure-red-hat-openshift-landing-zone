#!/bin/bash

source helper_vars.sh

# CREATE THE RESOURCE GROUPS
export SCOPE_HUB=$(az group create -n $HUB_RG -l $LOCATION --query id -o tsv)
export SCOPE_SPOKE=$(az group create -n $SPOKE_RG -l $LOCATION --query id -o tsv)
export SCOPE_SERVICES=$(az group create -n $SERVICES_RG -l $LOCATION --query id -o tsv)

# Create Resource Groups then Assign and Scope Contributor and User Access Administrator Permissions
az role assignment create --assignee $AAD_APP_CLIENT_ID --role contributor --scope $SCOPE_HUB 
az role assignment create --assignee $AAD_APP_CLIENT_ID --role contributor --scope $SCOPE_SPOKE 
az role assignment create --assignee $AAD_APP_CLIENT_ID --role contributor --scope $SCOPE_SERVICES
az role assignment create --assignee $AAD_APP_CLIENT_ID --role "User Access Administrator" --scope $SCOPE_SPOKE
az role assignment create --assignee $AAD_APP_CLIENT_ID --role "User Access Administrator" --scope $SCOPE_SERVICES

# CONFIGURE ENTRA APP REGISTRATION/SERVICE PRINCIPAL FOR OPENSHIFT OAUTH
az rest --method PATCH --url $GRAPH_URL --headers Content-Type=application/json --body '{"web":{"redirectUris":["'$REDIRECT_URL'"]}}' &
az ad app update --id $AAD_APP_REG_OBJECT_ID --set optionalClaims='{"idToken": [{"name": "email","essential": false,"additionalProperties": []}, {"name": "preferred_username","essential": false,"additionalProperties": []}, {"name": "groups","source": "groups","essential": false}], "accessToken": [{"name": "groups","source": "groups","essential": false}]}' &
az ad app update --id $AAD_APP_REG_OBJECT_ID --set groupMembershipClaims=SecurityGroup &
az ad sp update --id $AAD_APP_CLIENT_ID --set 'tags=["WindowsAzureActiveDirectoryIntegratedApp"]'
az ad app federated-credential create --id $AAD_APP_CLIENT_ID --parameters "{\"name\":\"${GH_ORGANISATION}-${GH_REPO}\",\"issuer\":\"${SERVICE_ACCOUNT_ISSUER}\",\"subject\":\"repo:${GH_ORGANISATION}/${GH_REPO}:ref:refs/heads/${GH_BRANCH}\",\"description\":\"Github Actions service account federated identity\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
az ad app permission add --api 00000003-0000-0000-c000-000000000000 --api-permissions 64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0=Scope --id $AAD_APP_CLIENT_ID &
az ad app permission add --api 00000003-0000-0000-c000-000000000000 --api-permissions 14dad69e-099b-42c9-810b-d002981feec1=Scope --id $AAD_APP_CLIENT_ID &
az ad app permission add --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope --id $AAD_APP_CLIENT_ID &

wait

az keyvault purge -n $KEYVAULT_NAME