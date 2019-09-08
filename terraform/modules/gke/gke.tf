# Module: gke
# File: gke.tf



resource "google_project_service" "container" {
  project    = "${terraform.workspace}"
  service    = "container.googleapis.com"
}

resource "google_project_service" "compute" {
  project    = "${terraform.workspace}"
  service    = "compute.googleapis.com"
}


data "google_compute_zones" "available" {
  provider = "google-beta"
  depends_on = [ "google_project_service.compute" ]
  region = "${var.region["single"]}"
}


locals { 
  kubernetes_version = "1.13"
}


resource "google_container_cluster" "kubernetes-cluster" {
  provider = "google-beta"
  depends_on = [
    "google_project_service.container",
    "google_compute_subnetwork.vpc_subnet_kubernetes",
    "data.google_compute_zones.available"
  ]

  name         = "kubernetes-cluster"
  location     = "${var.region["single"]}"
  node_locations = [
    "${data.google_compute_zones.available.names[0]}",
    "${data.google_compute_zones.available.names[1]}",
    "${data.google_compute_zones.available.names[2]}"
  ]

  min_master_version = "${local.kubernetes_version}"
  node_version = "${local.kubernetes_version}"

  #network = "${module.vpc-networking.compute_network.compute_network.name}"
  network = "${var.compute_network}"
  subnetwork = "${google_compute_subnetwork.vpc_subnet_kubernetes.name}"
  ip_allocation_policy {
    cluster_secondary_range_name = "kubernetes-pods"
    services_secondary_range_name = "kubernetes-services"
  }
 
  initial_node_count = 1

  node_config {
    tags = ["kubernetes"]
    preemptible  = true
    machine_type = "n1-standard-2"
    disk_size_gb    = 50
    oauth_scopes = [
      "cloud-platform"
    ]

    labels = {
      "cloud.google.com/gke-preemptible" = "true"
    }
  }

  cluster_autoscaling {
    enabled = true
    resource_limits {
         resource_type = "cpu"
         maximum = 4
      }
    resource_limits {
         resource_type = "memory"
         maximum = 32
      }
  }

  monitoring_service = "monitoring.googleapis.com/kubernetes"
  logging_service    = "logging.googleapis.com/kubernetes"

  addons_config {
    kubernetes_dashboard {
      disabled = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  lifecycle {
    ignore_changes = [
      node_version,
      node_locations
    ]
  }
}
