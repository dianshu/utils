#!/bin/bash
# reference: https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/create-vm-dual-stack-ipv6-cli

# set -ex

UNIQUE_ID=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8`
RESOURCE_GROUP="tool-$UNIQUE_ID"
LOCATION="SoutheastAsia"
VNET_NAME="vnet-$UNIQUE_ID"
SUBNET_NAME="subnet-$UNIQUE_ID"
PUBLIC_IPV4_NAME="ipv4-$UNIQUE_ID"
PUBLIC_IPV6_NAME="ipv6-$UNIQUE_ID"
NSG_NAME="nsg-$UNIQUE_ID"
NIC_NAME="nic-$UNIQUE_ID"
IPV6_CONFIG="config-$UNIQUE_ID"
VM_NAME="vm-$UNIQUE_ID"
VM_USER="fei"
VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"

# delete resource group if exists
az group delete -y --name $RESOURCE_GROUP || true

# create resource group
az group create --name  $RESOURCE_GROUP --location $LOCATION

# create vnet
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --name $VNET_NAME \
    --address-prefixes 10.0.0.0/16 2404:f800:8000:122::/64 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefixes 10.0.0.0/24 2404:f800:8000:122::/64

# create public ipv4
az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IPV4_NAME \
    --sku Standard \
    --version IPv4 \
    --zone 1 2 3

# create public ipv6
az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IPV6_NAME \
    --sku Standard \
    --version IPv6 \
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


# create ipv6 config
az network nic ip-config create \
    --resource-group $RESOURCE_GROUP \
    --name $IPV6_CONFIG \
    --nic-name $NIC_NAME \
    --private-ip-address-version IPv6 \
    --vnet-name $VNET_NAME \
    --subnet $SUBNET_NAME \
    --public-ip-address $PUBLIC_IPV6_NAME

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
    --security-type TrustedLaunch \
    --query "publicIpAddress" \
    --output tsv`

echo "Cmd to login: ssh $VM_USER@$public_ip"
echo "password: $password"
