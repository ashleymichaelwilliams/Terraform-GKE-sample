# Module: vpc-networking/
# File: compute_network.tf



resource "google_project_service" "compute" {
#  disable_dependent_services = true
  project    = "${var.google_project}"
  service    = "compute.googleapis.com"
}



resource "google_compute_network" "vpc-network" {
  depends_on = [
    "google_project_service.compute"
  ]
  name                      = "vpc-network"
  project                   = "${var.google_project}"
  auto_create_subnetworks   = "false"
}
