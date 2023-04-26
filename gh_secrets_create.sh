#!/bin/bash
export GH_REPOSITORY="<insert gh repository here format: user/repository>"
export LOCATION="<insert azure region where you would like to deploy resources>"
export HUB_RG="<insert name of the Hub Networking resource group>"
export SERVICES_RG="<insert name of resource group containing services>"
export SPOKE_RG="<insert name of spoke resource group containing ARO>"
export SP_NAME="<insert the name of the Azure Service Principal (or app registration) that you created>"
export AAD_ADMIN_GROUP_ID="<insert the id of the AAD group containing openshift administrators - az ad group show -g <MY AAD GROUP NAME> --query id -o tsv>"
export PAT_GITHUB="<insert your github personal access token>"
export JUMPBOX_ADMIN_USER="<insert username for the windows 11 jumpbox>"
export JUMPBOX_ADMIN_PWD="<insert the password for the windows 11 jumpbox>"

export GH_RUNNER_VERSION="<insert latest github runner version from https://github.com/actions/runner/releases/>"
export HELM_VERSION="<insert latest helm version from https://github.com/helm/helm/releases>"

export TENANT_ID=$(cat sp.txt | jq -r .tenantId)
export AZURE_SUBSCRIPTION=$(az account show --query id -o tsv)
export AZURE_CREDENTIALS=$(cat sp.txt)
export AAD_CLIENT_ID=$(az ad sp list --show-mine --query "[?displayName == '$SP_NAME'].appId" -o tsv)
export AAD_CLIENT_SECRET=$(cat sp.txt | jq -r .clientSecret)
export AAD_OBJECT_ID=$(az ad sp show --id $AAD_CLIENT_ID --query id -o tsv)
export ARO_RP_OB_ID=$(az ad sp list --all --query "[?appDisplayName=='Azure Red Hat OpenShift RP'].id" -o tsv)
export PULL_SECRET=$(cat pull-secret.json | sed 's/"/\\"/g')
export ACR_USERNAME="00000000-0000-0000-0000-000000000000"
export CONTAINER_BUILD_NAME="aro-github-runner:1"

# gh auth logout
# gh auth login
#Set the github repo
gh secret list -R $GH_REPOSITORY
printf "\n"

# List GH variables
gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables

# AZURE_SUBSCRIPTION
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='AZURE_SUBSCRIPTION' \
 -f value=$AZURE_SUBSCRIPTION 

# HUB_RG
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='HUB_RG' \
 -f value=$HUB_RG 

# SERVICES_RG
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='SERVICES_RG' \
 -f value=$SERVICES_RG

# SPOKE_RG
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='SPOKE_RG' \
 -f value=$SPOKE_RG

# GH_REPOSITORY
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='GH_REPOSITORY' \
 -f value=$GH_REPOSITORY 

# LOCATION
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='LOCATION' \
 -f value=$LOCATION 

# ACR_USERNAME
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='ACR_USERNAME' \
 -f value=$ACR_USERNAME 

# CONTAINER_BUILD_NAME
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='CONTAINER_BUILD_NAME' \
 -f value=$CONTAINER_BUILD_NAME

# GH_RUNNER_VERSION
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='GH_RUNNER_VERSION' \
 -f value=$GH_RUNNER_VERSION

# HELM_VERSION
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_REPOSITORY/actions/variables \
  -f name='HELM_VERSION' \
 -f value=$HELM_VERSION

gh secret set TENANT_ID --body "$TENANT_ID" -R $GH_REPOSITORY
gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS" -R $GH_REPOSITORY
gh secret set AAD_ADMIN_GROUP_ID --body "$AAD_ADMIN_GROUP_ID" -R $GH_REPOSITORY
gh secret set AAD_CLIENT_ID --body "$AAD_CLIENT_ID" -R $GH_REPOSITORY
gh secret set AAD_CLIENT_SECRET --body "$AAD_CLIENT_SECRET" -R $GH_REPOSITORY 
gh secret set AAD_OBJECT_ID --body "$AAD_OBJECT_ID" -R $GH_REPOSITORY
gh secret set ARO_RP_OB_ID --body "$ARO_RP_OB_ID" -R $GH_REPOSITORY
gh secret set JUMPBOX_ADMIN_USER --body "$JUMPBOX_ADMIN_USER" -R $GH_REPOSITORY
gh secret set JUMPBOX_ADMIN_PWD --body "$JUMPBOX_ADMIN_PWD" -R $GH_REPOSITORY
gh secret set PULL_SECRET --body "$PULL_SECRET" -R $GH_REPOSITORY
gh secret set PAT_GITHUB --body "$PAT_GITHUB" -R $GH_REPOSITORY