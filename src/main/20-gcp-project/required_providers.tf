terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.75.1"
      configuration_aliases = [
        google.tokengen,
        google.provision,
      ]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
