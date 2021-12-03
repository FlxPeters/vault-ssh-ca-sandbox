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
      hash2 : sha256(file("docker/ssh/sshd_config"))
    }
  }
}

resource "docker_container" "ssh_server" {
  name  = "ssh-server"
  image = docker_image.ssh_server.latest
  ports {
    internal = 22
    external = 2222
  }
  env = [
    "SSH_TRUSTED_USER_CA_KEYS=${data.terraform_remote_state.vault.outputs.ssh_ca_public_key}"
  ]
}