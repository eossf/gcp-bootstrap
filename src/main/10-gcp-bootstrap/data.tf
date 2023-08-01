data "google_client_config" "default" {
  provider = google.tokengen
}

data "google_service_account_access_token" "sa" {
  provider = google.tokengen
  target_service_account = var.sa
  lifetime               = "3600s"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}