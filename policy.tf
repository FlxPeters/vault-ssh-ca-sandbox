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