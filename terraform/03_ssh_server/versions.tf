terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
     vault = {
      source  = "hashicorp/vault"
      version = "3.0.1"
    }
  }
}
