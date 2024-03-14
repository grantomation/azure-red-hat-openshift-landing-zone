#!/bin/bash

source helper_vars.sh

# Set the github repo
# gh api user -q .login
# gh auth logout
# gh auth login
# gh api user -q .login 

#fix the pagination
gh config set pager "less -FX"

# List GH Secrets
gh secret list -R $GH_REPOSITORY
printf "\n"

# List GH variables
gh variable list -R $GH_REPOSITORY
printf "\n"

# Set environment vars
gh variable set AZURE_SUBSCRIPTION --body $AZURE_SUBSCRIPTION -R $GH_REPOSITORY
gh variable set HUB_RG --body $HUB_RG -R $GH_REPOSITORY
gh variable set SERVICES_RG --body $SERVICES_RG -R $GH_REPOSITORY
gh variable set SPOKE_RG --body $SPOKE_RG -R $GH_REPOSITORY
gh variable set GH_REPOSITORY --body $GH_REPOSITORY -R $GH_REPOSITORY
gh variable set LOCATION --body $LOCATION -R $GH_REPOSITORY
gh variable set ACR_USERNAME --body $ACR_USERNAME -R $GH_REPOSITORY
gh variable set CONTAINER_BUILD_NAME --body $CONTAINER_BUILD_NAME -R $GH_REPOSITORY

# Set secrets
gh secret set TENANT_ID --body "$TENANT_ID" -R $GH_REPOSITORY
gh secret set AAD_ADMIN_GROUP_ID --body "$AAD_ADMIN_GROUP_ID" -R $GH_REPOSITORY
gh secret set AAD_APP_CLIENT_ID --body "$AAD_APP_CLIENT_ID" -R $GH_REPOSITORY
gh secret set AAD_SP_OBJECT_ID --body "$AAD_SP_OBJECT_ID" -R $GH_REPOSITORY
gh secret set ARO_RP_OB_ID --body "$ARO_RP_OB_ID" -R $GH_REPOSITORY
gh secret set JUMPBOX_ADMIN_USER --body "$JUMPBOX_ADMIN_USER" -R $GH_REPOSITORY
gh secret set JUMPBOX_ADMIN_PWD --body "$JUMPBOX_ADMIN_PWD" -R $GH_REPOSITORY
gh secret set PULL_SECRET --body "$PULL_SECRET" -R $GH_REPOSITORY
gh secret set PAT_GITHUB --body "$PAT_GITHUB" -R $GH_REPOSITORY
# Only set AAD_CLIENT_SECRET if env is set - to prevent overwriting with no value
if [ -n "$AAD_CLIENT_SECRET" ]; then
    gh secret set AAD_CLIENT_SECRET --body "$AAD_CLIENT_SECRET" -R $GH_REPOSITORY
else
    printf "\n"
    echo "WARNING: A value for AAD_CLIENT_SECRET was not set"
    printf "\n"
fi