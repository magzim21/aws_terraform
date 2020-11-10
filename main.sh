#!/bin/bash

key_file='awazon_key_pair'

terraform init 
#terraform plan

# Generating  ssh key-pair. We will use it by specifinig `ssh -i awazon_key_pair user@host`
echo "Generating ssh ${key_file} and saving to cwd"
ssh-keygen -f ${key_file} -q  -N "" 

terraform apply --auto-approve 