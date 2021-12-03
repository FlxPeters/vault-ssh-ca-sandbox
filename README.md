# Vault SSH CA sandbox

A lab repo to demonstrate the usage of OpenSSH certificate usage with Vault. 

## Goals

* [x] Setup a Vault SSH CA via Terraform
* [x] Deploy a OpenSSH server as container using this CA
* [x] Connect as a human user to the SHS server using a signed key
* [x] Connect as a CI pipeline with meta data of this pipeline using a singed key
  * CI pipelines should be able to sign a SSH key with meta data from their identity as principal
  * All servers a pipeline should have access to  must allow access by adding the pipeline principal to the `auth_principals` file of a linux user.
  * This allows fine grained access control without creating new users for each pipeline etc. 
* [ ] Get password less sudo access based on the certificate
  * Disabling authentication on for sudo would give root access to an attacker if  they can own our user from outside (e.g. web shell).
  * This adds a extra layer of security to an elevated access like sudo to root 
  * Root should not be available via SSH (I know, facebook says this is ok, i don't think so)
* [ ] Sign a host key on creation to allow host key verification from the client side

## Usage

The project is split up in several Terraform states located at `terraform`.
Each state represents a sub set of necessary building blocks for an SSH CA. Ths could have been one state, but i split them up for better readability.

Docker containers are created using Terraform .This could have been done with Docker-Compose but i just want to try out using docker for this task. 

## Links and resources

* https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates
* https://brian-candler.medium.com/using-hashicorp-vault-as-an-ssh-certificate-authority-14d713673c9a
* https://cottonlinux.com/ssh-certificates/
* https://medium.com/uber-security-privacy/introducing-the-uber-ssh-certificate-authority-4f840839c5cc
* https://engineering.fb.com/2016/09/12/security/scalable-and-secure-access-with-ssh/
* https://medium.com/hashicorp-engineering/hashicorp-vault-ssh-ca-and-sentinel-79ea6a6960e5

## License

MIT