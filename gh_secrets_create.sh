#!/bin/bash

source helper_vars.sh

# gh auth logout
# gh auth login
# Set the github repo

#fix the pagination
gh config set pager "less -FX"
gh secret list -R $GH_REPOSITORY
printf "\n"

# List GH variables
gh variable list -R $GH_REPOSITORY

gh variable set AZURE_SUBSCRIPTION --body $AZURE_SUBSCRIPTION -r $GH_REPOSITORY
gh variable set HUB_RG --body $HUB_RG
gh variable set SERVICES_RG --body $SERVICES_RG
gh variable set SPOKE_RG --body $SPOKE_RG
gh variable set GH_RESPOSITORY --body $GH_REPOSITORY
gh variable set LOCATION --body $LOCATION
gh variable set ACR_USERNAME --body $ACR_USERNAME
gh variable set CONTAINER_BUILD_NAME --body $CONTAINER_BUILD_NAME
gh variable set GH_RUNNER_VERSION --body $GH_RUNNER_VERSION
gh variable set HELM_VERSION --body $HELM_VERSION

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