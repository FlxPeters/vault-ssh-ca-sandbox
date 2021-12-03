// Create a userpass entity to simulate a CI pipeline
// This would be a JWT from Gitlab for example

// https://docs.gitlab.com/ee/ci/examples/authenticating-with-hashicorp-vault/#how-it-works
// Demo content of a JWT: 
// "namespace_id": "1",
// "namespace_path": "mygroup",
// "project_id": "22",
// "project_path": "mygroup/myproject",
// "user_id": "42",
// "user_login": "myuser",
// "user_email": "myuser@example.com",
// "pipeline_id": "1212",
// "pipeline_source": "web",
// "job_id": "1212",
// "ref": "auto-deploy-2020-04-01",
// "ref_type": "branch",
// "ref_protected": "true",
// "environment": "production",
// "environment_protected": "true"

resource "vault_generic_endpoint" "user_ci_pipeline" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/ci-pipeline"
  ignore_absent_fields = true

  data_json = jsonencode(
    {
      policies = [vault_policy.sign_ssh_devops_ci_pipeline.name],
      password = "ci"
  })
}
resource "vault_identity_entity" "ci_pipeline" {
  name = "ci-pipeline"
  metadata = {
    project_id            = "22"
    project_path          = "mygroup/myproject"
    ref_protected         = "true"
    environment           = "production"
    environment_protected = "true"
  }
}
resource "vault_identity_entity_alias" "ci_pipeline" {
  name           = "ci-pipeline"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.ci_pipeline.id
}

// Policy to access SSH backend role for CI pipelines

data "vault_policy_document" "sign_ssh_devops_ci_pipeline" {
  rule {
    path         = "ssh/sign/${vault_ssh_secret_backend_role.ci_pipeline.name}"
    capabilities = ["create", "read", "update"]
    description  = "Allow signing SSH keys for this role"
  }
}
resource "vault_policy" "sign_ssh_devops_ci_pipeline" {
  name   = "sign_ssh_devops_ci_pipeline"
  policy = data.vault_policy_document.sign_ssh_devops_ci_pipeline.hcl
}
