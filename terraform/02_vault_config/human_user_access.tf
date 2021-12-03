// Setup a human user "bob" with permissions to sign SSH keys
// Bob is member of the group "devops" which has the permssions.
// This is because humans should always be organized in groups and should not have 
// direct assigned policies
// See: https://learn.hashicorp.com/tutorials/vault/identity

// Use best practive to only apply policies to groups
resource "vault_identity_group" "devops" {
  name                       = "devops"
  type                       = "internal"
  external_member_entity_ids = true
  policies                   = [vault_policy.sign_ssh_devops_default.name]
  metadata = {
    version = "2"
  }
}

// Generic user pass object bob for test purpose
resource "vault_generic_endpoint" "user_bob" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/bob"
  ignore_absent_fields = true

  data_json = jsonencode(
    {
      password = "bob"
  })
}

// Create vault entity for bob
resource "vault_identity_entity" "bob" {
  name = "bob"
}
// Map userpass bob to enity bob
// Bob could also have another auth endpoint which could then
// be mapped to this internal entity
resource "vault_identity_entity_alias" "bob" {
  name           = "bob"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.bob.id
}

// Assign members to group
resource "vault_identity_group_member_entity_ids" "devops_members" {
  exclusive         = false
  member_entity_ids = [vault_identity_entity.bob.id]
  group_id          = vault_identity_group.devops.id
}

// Policies
data "vault_policy_document" "sign_ssh_devops_default" {
  rule {
    path         = "ssh/sign/${vault_ssh_secret_backend_role.devops_default.name}"
    capabilities = ["create", "read", "update"]
    description  = "Allow signing Keys to grant access to user ops"
  }
}
resource "vault_policy" "sign_ssh_devops_default" {
  name   = "sign_ssh_devops_default"
  policy = data.vault_policy_document.sign_ssh_devops_default.hcl
}

// SSH backend role for DevOps users on linux servers
// Allow to sign keys which grant access to user ops
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


