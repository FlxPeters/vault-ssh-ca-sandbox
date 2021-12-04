output "ssh_ca_public_key" {
    value = vault_ssh_secret_backend_ca.ssh.public_key
}

output "app_role_path" {
    value = vault_auth_backend.approle.path
}
output "host_key_signing_app_role_name" {
    value = vault_approle_auth_backend_role.host_key_signing.role_name
}
output "host_key_signing_app_role_id" {
    value = vault_approle_auth_backend_role.host_key_signing.role_id
}

output "host_key_signing_backend_role_name" {
    value = vault_ssh_secret_backend_role.devops_host_key.name
}