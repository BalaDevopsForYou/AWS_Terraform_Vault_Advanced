terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "5.11.0"
    }
    vault={
        source = "hashicorp/vault"
        version = "3.20.1"
    }
  }
}


provider "aws" {
    region = var.region
    access_key = data.vault_generic_secret.my_access_key.data["access_key"]
    secret_key = data.vault_generic_secret.my_secret_key.data["secret_key"]
  
}

provider "vault" {
    address = "http://127.0.0.1:8200"
}