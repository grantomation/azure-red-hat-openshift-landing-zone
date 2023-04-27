#!/bin/bash

source helper_vars.sh

zone=("privatelink.azurecr.io" "privatelink.vaultcore.azure.net" "privatelink.blob.core.windows.net" "privatelink.oms.opinsights.azure.com" "privatelink.ods.opinsights.azure.com" "privatelink.monitor.azure.com" "privatelink.agentsvc.azure-automation.net
")

for dns in "${zone[@]}"
do
    for LINK in $(az network private-dns link vnet list -g $HUB_RG -z $dns --query [].name -o tsv); do
        echo "Deleting private-dns-link $LINK from $dns"
        az network private-dns link vnet delete -n $LINK -g $HUB_RG -z $dns -y &
    done
done

az monitor log-analytics workspace delete -n $LAW -g $SERVICES_RG --force yes -y

echo "Deleting $HUB_RG"
az group delete -n $HUB_RG -y &

echo "Deleting $SERVICES_RG"
az group delete -n $SERVICES_RG -y &

echo "Deleting $SPOKE_RG"
az group delete -n $SPOKE_RG -y &

wait

az keyvault purge -n $KEYVAULT_NAME