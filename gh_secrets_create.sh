#!/bin/bash
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