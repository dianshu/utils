#!/bin/bash
# reference: https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/create-vm-dual-stack-ipv6-cli

UNIQUE_ID=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8`
RESOURCE_GROUP="tool-$UNIQUE_ID"
LOCATION="SoutheastAsia"
VNET_NAME="vnet-$UNIQUE_ID"
SUBNET_NAME="subnet-$UNIQUE_ID"
PUBLIC_IPV4_NAME="ipv4-$UNIQUE_ID"
NSG_NAME="nsg-$UNIQUE_ID"
NIC_NAME="nic-$UNIQUE_ID"
IPV6_CONFIG="config-$UNIQUE_ID"
VM_NAME="vm-$UNIQUE_ID"
VM_USER="fei"
VM_IMAGE="Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
set -ex

# delete resource group if exists
az group delete -y --name $RESOURCE_GROUP || true

# create resource group
az group create --name  $RESOURCE_GROUP --location $LOCATION

# create vnet
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --name $VNET_NAME \
    --address-prefixes 10.0.0.0/16 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefixes 10.0.0.0/24

# create public ip
az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IPV4_NAME \
    --sku Standard \
    --version IPv4 \
    --zone 1 2 3

# create nsg
az network nsg create --resource-group $RESOURCE_GROUP --name $NSG_NAME

# create nsg rules
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name NSGRuleSSH \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 22 \
    --access allow \
    --priority 200
     
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name NSGRule443 \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 443 \
    --access allow \
    --priority 202

az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name NSGRule80 \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 203

az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name NSGRuleAllOUT \
    --protocol '*' \
    --direction outbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range '*' \
    --access allow \
    --priority 200

# create nic
az network nic create \
    --resource-group $RESOURCE_GROUP \
    --name $NIC_NAME \
    --vnet-name $VNET_NAME \
    --subnet $SUBNET_NAME \
    --network-security-group $NSG_NAME \
    --public-ip-address $PUBLIC_IPV4_NAME

# create vm
password=`head /dev/urandom | tr -dc A-Za-z0-9.,[] | head -c 50`
public_ip=`az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --nics $NIC_NAME \
    --admin-username $VM_USER \
    --admin-password $password \
    --authentication-type password \
    --image $VM_IMAGE \
    --size Standard_D2ds_v5 \
    --query "publicIpAddress"` \
    --output tsv

echo "Cmd to login: ssh $VM_USER@$public_ip"
echo "password: $password"

cat <<EOF
Cmd to add inbound rule:
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name NSGRule34512 \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 34512 \
    --access allow \
    --priority 201
EOF
