
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "vault" {
  name = "vault:1.9.0"
}

resource "docker_container" "vault" {
  name  = "vault"
  image = docker_image.vault.latest
  ports {
    internal = 8200
    external = 8200
  }
  env = [
    "VAULT_ADDR=http://127.0.0.1:8200",
    "VAULT_DEV_ROOT_TOKEN_ID=root-token"
  ]

  capabilities {
    add = ["IPC_LOCK"]
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "root-token"
}

resource "docker_image" "ssh_server" {
  name = "ssh-server"
  build {
    path = "docker/ssh"
    tag  = ["flxptrs/openssh:alpine"]
    label = {
      # Dirty hack to force rebuild image on changed files
      hash: sha256(file("docker/ssh/Dockerfile"))
      hash2: sha256(file("docker/ssh/docker-entrypoint.sh")) 
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
  env  = [
    "SSH_TRUSTED_USER_CA_KEYS=${vault_ssh_secret_backend_ca.ssh.public_key}"
  ]
}