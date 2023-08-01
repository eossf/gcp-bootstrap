resource "random_string" "suffix" {
  length      = 4
  special     = false
  numeric     = true
  min_numeric = 4
}

module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "14.2.1"
  org_id            = var.org_id
  folder_id         = var.parent_folder_id
  random_project_id = false
  project_id        = "${var.short_project_name}-${var.deployment_environment}-${random_string.suffix.result}"
  billing_account   = var.billing_account
  name              = "${var.long_project_name}-${random_string.suffix.result}"
  lien              = false

  grant_network_role = true

  activate_apis = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "dns.googleapis.com",
  ]

  disable_services_on_destroy = false
}
