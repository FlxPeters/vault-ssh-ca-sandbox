provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "root-token"
}

data "terraform_remote_state" "vault" {
  backend = "local"
  config = {
    path = "../02_vault_config/terraform.tfstate"
  }
}

resource "docker_image" "ssh_server" {
  name = "ssh-server"
  build {
    path = "docker/ssh"
    tag  = ["flxptrs/openssh:alpine"]
    label = {
      # Dirty hack to force rebuild image on changed files
      hash : sha256(file("docker/ssh/Dockerfile"))
      hash2 : sha256(file("docker/ssh/docker-entrypoint.sh"))
      hash3 : sha256(file("docker/ssh/sshd_config"))
      hash4 : sha256(file("docker/ssh/ssh-vault-sign-key.sh"))
    }
  }
}

// request a secret ID from fault for the given app role
resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = data.terraform_remote_state.vault.outputs.app_role_path
  role_name = data.terraform_remote_state.vault.outputs.host_key_signing_app_role_name
}
data "docker_network" "vault" {
  name = "vault"
}
resource "docker_container" "ssh_server" {
  name  = "ssh-server"
  image = docker_image.ssh_server.latest
  ports {
    internal = 22
    external = 2222
  }
  env = [
    "VAULT_ADDR=http://vault:8200",
    "SSH_TRUSTED_USER_CA_KEYS=${data.terraform_remote_state.vault.outputs.ssh_ca_public_key}",
    "SSH_KEY_SIGNING_APP_ROLE_ID=${data.terraform_remote_state.vault.outputs.host_key_signing_app_role_id}",
    "SSH_KEY_SIGNING_APP_SECRET_ID=${vault_approle_auth_backend_role_secret_id.this.secret_id}",
    "SSH_KEY_SIGNING_BACKEND_ROLE_NAME=${data.terraform_remote_state.vault.outputs.host_key_signing_backend_role_name}"
  ]
  networks_advanced {
    name = data.docker_network.vault.name
  }
}