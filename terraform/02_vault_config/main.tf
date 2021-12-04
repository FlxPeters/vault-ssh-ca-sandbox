provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "root-token"
}

// Seup a SSH certificate authority
resource "vault_mount" "ssh" {
  type = "ssh"
  path = "ssh"
}
resource "vault_ssh_secret_backend_ca" "ssh" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
}

// Auth backends
resource "vault_auth_backend" "userpass" {
  type       = "userpass"
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

// Audit log
resource "vault_audit" "stdout" {
  type = "file"
  options = {
    file_path = "stdout"
    log_raw = true
  }
}