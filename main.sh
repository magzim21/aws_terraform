#!/bin/bash
terraform init 
#terraform plan

# Generating  ssh key-pair. We will use it by specifinig `ssh -i awazon_key_pair user@host`
ssh-keygen -f awazon_key_pair -q  -N "" 

terraform apply 