#!/usr/bin/env bash

echo $DATABRICKS_HOST
echo $DATABRICKS_TOKEN
pip install databricks-cli --upgrade

# Change absolutely NOTHING.
# It would seem that the PAT Token That I was Running Off had expired! Ensure That The Environment Variables Are Set:
# DATABRICKS_HOST : It Must Start As https:// : It Must Not End In '/'
# DATABRICKS_TOKEN : It Must Not Be Expired. 


azKeyVaultName=$(az keyvault list -g $param_ResourceGroupName --query "[].name" -o tsv)
secret_val=$(az keyvault secret show --name "dbkstoken" --vault-name $AZ_KEYVAULT_NAME --query "value")


databricks configure --token 

echo "Test Databricks CLI Commands"
databricks -h 
databricks fs ls

#databricks fs mkdirs dbfs:/tmp/new-dir

