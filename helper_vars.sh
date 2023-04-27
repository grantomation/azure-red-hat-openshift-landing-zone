#!/bin/bash
export SP_FILE='<insert the filename where you saved service principal credentials. sp.txt if you followed README>'
export SP_NAME="<insert the name of the Azure Service Principal (or app registration) that you created>"

export GH_REPOSITORY="<insert gh repository here format: user/repository>"
export PAT_GITHUB="<insert your github personal access token>"

# Set Azure variables
export LOCATION="<insert azure region where you would like to deploy resources>"
export SERVICES_RG="<insert name of resource group containing services>"
export SPOKE_RG="<insert name of resource group containing ARO>"
export HUB_RG="<insert name of resource group hub network services>"
export AAD_ADMIN_GROUP_ID="<insert the id of the AAD group containing openshift administrators - az ad group show -g <MY AAD GROUP NAME> --query id -o tsv>"
# Set Tooling version vars
export GH_RUNNER_VERSION="<insert latest github runner version from https://github.com/actions/runner/releases/>"
export HELM_VERSION="<insert latest helm version from https://github.com/helm/helm/releases>"
# Set Jumpbox Vars
export JUMPBOX_ADMIN_USER="<insert username for the windows 11 jumpbox>"
export JUMPBOX_ADMIN_PWD="<insert the password for the windows 11 jumpbox>"
# Set Container Vars
export CONTAINER_BUILD_NAME="aro-github-runner:1"

# No need to modify these variables as they will self set
export CLUSTER_NAME=$(jq -r '.parameters.clusterName.value' action_params/aro.parameters.json)
export DOMAIN=$(jq -r '.parameters.domain.value' action_params/aro.parameters.json)
export HUB_RG=$(jq -r '.parameters.hubVnetName.value' action_params/hub_network.parameters.json)
export SPOKE_RG=$(jq -r '.parameters.spokeVnetName.value' action_params/spoke_network.parameters.json)
export KEYVAULT_NAME=$(jq -r '.parameters.keyVaultName.value' action_params/keyvault.parameters.json)
export LAW=$(jq -r '.parameters.lawName.value' action_params/law.parameters.json)
export TENANT_ID=$(cat $SP_FILE | jq -r .tenantId)
export AZURE_SUBSCRIPTION=$(az account show --query id -o tsv)
export AZURE_CREDENTIALS=$(cat $SP_FILE)
export AAD_CLIENT_ID=$(az ad sp list --show-mine --query "[?displayName == '$SP_NAME'].appId" -o tsv)
export AAD_APP_REG_OBJECT_ID=$(az ad app show --id $AAD_CLIENT_ID --query id -o tsv)
export GRAPH_URL=https://graph.microsoft.com/v1.0/applications/$AAD_APP_REG_OBJECT_ID
export REDIRECT_URL=https://oauth-openshift.apps.$DOMAIN.$LOCATION.aroapp.io/oauth2callback/AAD
export AAD_CLIENT_SECRET=$(cat $SP_FILE | jq -r .clientSecret)
export AAD_OBJECT_ID=$(az ad sp show --id $AAD_CLIENT_ID --query id -o tsv)
export ARO_RP_OB_ID=$(az ad sp list --all --query "[?appDisplayName=='Azure Red Hat OpenShift RP'].id" -o tsv)
export PULL_SECRET=$(cat pull-secret.json | sed 's/"/\\"/g')
# This is the default Username for ACR logins. Do not change
export ACR_USERNAME="00000000-0000-0000-0000-000000000000"