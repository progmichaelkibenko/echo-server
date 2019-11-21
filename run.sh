#!/bin/bash          
client_id="523893b6-bfeb-489f-a5d9-e2f6e0e9f94f"
client_secret="dHMeTVH=mZeE:4x:3YF=m1tA9nRnn@p."
subscription_id="f3e0167f-3e80-42f1-a42f-c8abc0655c11"
tenant_id="700123f5-16bf-4143-a6a6-d0bf7526e03d"
image_name="EchoServerImage"
ressource_group="packerDemoRessourceGroup"
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




