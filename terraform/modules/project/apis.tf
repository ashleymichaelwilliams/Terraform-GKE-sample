# Module: project
# File: apis.tf



resource "google_project_service" "monitoring" {
  project = "${terraform.workspace}"
  service = "monitoring.googleapis.com"
}


resource "google_project_service" "logging" {
  project = "${terraform.workspace}"
  service = "logging.googleapis.com"
}

