#!/bin/bash

# Demonstrate a CI pipeline run 

# Generate  new private key
ssh-keygen -t rsa -f ./id_rsa_ci -N ""

# Sign in to vault 
export VAULT_ADDR=http://127.0.0.1:8200
vault login -method=userpass username=ci-pipeline

# Create a cert for user ops with a gitlab project id mathcing the id in our vault CI users metadata
vault write -field=signed_key ssh/sign/devops-ci-pipeline valid_principals="gitlab-project-id-22" public_key=@./id_rsa_ci.pub > id_rsa_ci.cert.pub
ssh-keygen -L -f id_rsa_ci.cert.pub

# Test if we can connect as ops
ssh  -i ./id_rsa_ci -i id_rsa_ci.cert.pub ops@127.0.0.1 -p 2222 -C "whoami"