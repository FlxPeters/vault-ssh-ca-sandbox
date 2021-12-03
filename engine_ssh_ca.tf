// Seup a SSH certificate authority
resource "vault_mount" "ssh" {
  type = "ssh"
  path = "ssh"
}
resource "vault_ssh_secret_backend_ca" "ssh" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
}

// Add SSH CA roles - Base concept is a separation in default users and admin usrs.
// This should allow less priviledged access for day to day work and maybe inerns. 
// Admin should be used for modification of the system state and grants root access

// Non priviledged role for DevOps users linux servers
// Should only read access without root access
resource "vault_ssh_secret_backend_role" "devops_default" {
  name                    = "devops-default"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = true
  // required for alpine open-ssh to work
  algorithm_signer   = "rsa-sha2-256"
  ttl                = 60*60*24
  max_ttl            = 60*60*24
  allowed_extensions = "permit-pty,permit-port-forwarding"
  default_extensions = { permit-pty = "" }
  allowed_users      = "ops"
  default_user       = "ops"
}

resource "vault_ssh_secret_backend_role" "ci_pipeline" {
  name                    = "devops-ci-pipeline"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = true
  algorithm_signer   = "rsa-sha2-256"
  // short lived certs for CI
  ttl                = 60
  max_ttl            = 60
  allowed_extensions = "permit-pty"
  default_extensions = { permit-pty = "" }
  allowed_users_template =  true
  allowed_users = "gitlab-project-id-{{identity.entity.metadata.project_id}}"
}

// // Priviledged role for DevOps users linux servers
// // Should allow full access to linux servers
// resource "vault_ssh_secret_backend_role" "devops_admin" {
//     name                    = "devops-admin"
//     backend                 = vault_mount.ssh.path
//     key_type                = "ca"
//     allow_user_certificates = true
//     ttl = 120
//     max_ttl = 3600
//     allowed_users = "devops-admin"
//     default_user = "devops-admin"
// }

// // Role to generate host keys
// resource "vault_ssh_secret_backend_role" "hostkeys" {
//     name                    = "hostkey"
//     backend                 = vault_mount.ssh.path
//     key_type                = "ca"
//     allow_user_certificates = false
//     allow_host_certificates = true

//     // Default TTF of 10 years
//     ttl = 60*60*24*365*10
// }

