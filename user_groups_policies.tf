// See: https://learn.hashicorp.com/tutorials/vault/identity

resource "vault_auth_backend" "userpass" {
  type       = "userpass"
  depends_on = [docker_container.vault]
}

// Use best practive to only apply policies to groups
resource "vault_identity_group" "devops" {
  name                       = "devops"
  type                       = "internal"
  external_member_entity_ids = true
  policies                   = [vault_policy.manage_secrets_devops.name, vault_policy.sign_ssh_devops_default.name]

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
data "vault_policy_document" "manage_secrets_devops" {
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow management of all secrests for group devops"
  }
}
resource "vault_policy" "manage_secrets_devops" {
  name   = "manage_secrets_devops"
  policy = data.vault_policy_document.manage_secrets_devops.hcl
}

data "vault_policy_document" "sign_ssh_devops_default" {
  rule {
    path         = "ssh/*"
    capabilities = ["list"]
    description  = "Allow list all SSH secret path"
  }
  rule {
    path         = "ssh/sign/devops-default"
    capabilities = ["create", "read", "update"]
    description  = "Allow usage of SSH backend role devops-default"
  }
}
resource "vault_policy" "sign_ssh_devops_default" {
  name   = "sign_ssh_devops_default"
  policy = data.vault_policy_document.sign_ssh_devops_default.hcl
}
