#!/bin/bash
# reference: https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/create-vm-dual-stack-ipv6-cli

RESOURCE_GROUP="ipv6"
LOCATION="SoutheastAsia"
VNET_NAME="ipv6-vnet"
SUBNET_NAME="ipv6-subnet"
PUBLIC_IPV4_NAME="public-ipv4"
PUBLIC_IPV6_NAME="public-ipv6"
NSG_NAME="ipv6_nsg"
NIC_NAME="ipv6_nic"
IPV6_CONFIG="ipv6_config"
VM_NAME="ipv6_vm"
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
    --address-prefixes 10.0.0.0/16 2404:f800:8000:122::/63 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefixes 10.0.0.0/24 2404:f800:8000:122::/64

# create public ip, including ipv4 and ipv6
az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IPV4_NAME \
    --sku Standard \
    --version IPv4 \
    --zone 1 2 3

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
     --name NSGRuleSSH34512 \
     --protocol '*' \
     --direction inbound \
     --source-address-prefix '*' \
     --source-port-range '*' \
     --destination-address-prefix '*' \
     --destination-port-range 34512 \
     --access allow \
     --priority 201

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
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --nics $NIC_NAME \
    --image UbuntuLTS \
    --admin-username $VM_USER \
    --authentication-type ssh \
    --generate-ssh-keys \
    --image $VM_IMAGE
