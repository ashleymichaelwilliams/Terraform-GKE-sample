# Module: project/
# File: apis.tf



resource "google_project_service" "monitoring" {
  depends_on = [ 
    "google_project.project"
  ]
  project = "${var.google_project}"
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "logging" {
  depends_on = [
    "google_project.project"
  ]
  project = "${var.google_project}"
  service = "logging.googleapis.com"
}

