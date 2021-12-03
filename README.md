# Vault SSH CA sandbox

A lab repo to demonstrate the usage of OpenSSH certificate usage with Vault. 

## Goals

* [x] Setup a Vault SSH CA via Terraform
* [x] Deploy a OpenSSH server as container using this CA
* [x] Connect as a human user to the SHS server using a signed key
* [x] Connect as a CI pipeline with meta data of this pipeline using a singed key
* [ ] Get passwordless sudo access based on the certificate
  * Disabling authentication on for sudo would give root access to an attacker if  they can own our user from outside (e.g. web shell).
  * This ads a extra layer of security to an elevated access like sudo to root 
  * Root should not be available via SSH

## Usage

The project is split up in several Terraform states located at `terraform`.
Each state represents a sub set of necessary building blocks for an SSH CA. Ths could have been one state, but i split them up for better readability.

Docker containers are created using Terraform .This could have been done with Docker-Compose but i just want to try out using docker for this task. 

# Links and resources

* https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates
* https://brian-candler.medium.com/using-hashicorp-vault-as-an-ssh-certificate-authority-14d713673c9a
* https://cottonlinux.com/ssh-certificates/

# License

MIT