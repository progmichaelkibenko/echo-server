#!/bin/bash          
client_id=""
client_secret=""
subscription_id=""
tenant_id=""
image_name="EchoServerImage"
ressource_group=""
location="West Europe"

#build packer image
cd packer

./packer build -var "client_id=${client_id}" -var "client_secret=${client_secret}" -var "subscription_id=${subscription_id}" -var "tenant_id=${tenant_id}" -var "image_name=${image_name}" -var "ressource_group=${ressource_group}" -var "location=${location}" packer-deploy-azure.json

cd ..
#end build packer image

#build loadBalancer via terraform

cd terraform

./terraform init
./terraform plan -var "subscription_id=${subscription_id}" -var "client_id=${client_id}" -var "client_secret=${client_secret}" -var "tenant_id=${tenant_id}" -var "azurerm_image=${image_name}" -var "azurerm_resource_group=${ressource_group}" -var "location=${location}"
./terraform apply

cd ..
#end build loadBalancer via terraform




