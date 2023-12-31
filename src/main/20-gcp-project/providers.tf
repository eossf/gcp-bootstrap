provider "google" {
  alias = "tokengen"
}

provider "google" {
  alias        = "provision"
  access_token = data.google_service_account_access_token.sa.access_token
  project      = var.host_project_id
}

provider "random" {}