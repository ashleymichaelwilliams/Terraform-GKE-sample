# Module: kubernetes/
# File: compute_subnetworks.tf



resource "google_compute_subnetwork" "vpc_subnet_kubernetes" {
  depends_on = [
    "google_project_service.compute"
  ]
  name          = "kubernetes"
  project       = "${var.google_project}"
  network       = "${var.compute_network}"
  region        = "${var.region["single"]}"
  ip_cidr_range = "10.100.160.0/19"
  private_ip_google_access = true

  secondary_ip_range = [
    {
      range_name    = "kubernetes-pods"
      ip_cidr_range = "10.100.0.0/17"
    },
    {
      range_name    = "kubernetes-services"
      ip_cidr_range = "10.100.192.0/18"
    }
  ]
}
