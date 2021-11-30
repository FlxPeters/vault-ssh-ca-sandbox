
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