# Module: project/
# File: outputs.tf



output "google_project" {
  value = "${google_project.project.project_id}"
}
