#!/bin/bash

# Generate  new private key
ssh-keygen -t rsa -C "bob" -f ./id_rsa_bob -N ""

# Sign in to vault 
export VAULT_ADDR=http://127.0.0.1:8200
vault login -method userpass username=bob

# Create a cert for user ops
vault write -field=signed_key ssh/sign/devops-default public_key=@./id_rsa_bob.pub > id_rsa_bob.cert.pub
ssh-keygen -L -f id_rsa_bob.cert.pub

ssh  -i ./id_rsa_bob -i id_rsa_bob.cert.pub ops@127.0.0.1 -p 2222