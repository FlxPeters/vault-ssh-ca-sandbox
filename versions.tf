terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.0.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}
