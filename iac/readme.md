Installieren der Azure CLI
winget install --exact --id Microsoft.AzureCLI

Login:
az login --tenant <<id>>
az account show

az deployment sub what-if --location westeurope --template-file main.bicep 
az deployment sub create --location westeurope --template-file main.bicep 
