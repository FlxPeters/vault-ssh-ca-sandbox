
resource "vault_approle_auth_backend_role" "host_key_signing" {
  backend        = vault_auth_backend.approle.path
  role_name      = "host-key-signing"
  token_policies = [vault_policy.sign_ssh_devops_hosts.name]
}

// SSH backend role for host key signing
// Allow to sign host keys from servers of the devops group
resource "vault_ssh_secret_backend_role" "devops_host_key" {
  name                    = "devops-sign-host-key"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = false
  allow_host_certificates = true
  // required for alpine open-ssh to work
  algorithm_signer   = "rsa-sha2-256"
}

// Policies
data "vault_policy_document" "sign_ssh_devops_hosts" {
  rule {
    path         = "ssh/sign/${vault_ssh_secret_backend_role.devops_host_key.name}"
    capabilities = ["create", "read", "update"]
    description  = "Allow signing of host keys from devops servers"
  }
}
resource "vault_policy" "sign_ssh_devops_hosts" {
  name   = "sign_ssh_devops_hosts"
  policy = data.vault_policy_document.sign_ssh_devops_hosts.hcl
}