# Module: kubernetes/
# File: kubernetes.tf



resource "google_project_service" "compute" {
  project    = "${terraform.workspace}"
  service    = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project    = "${terraform.workspace}"
  service    = "container.googleapis.com"
}



# Collect Availability Zones
data "google_compute_zones" "available" {
  provider = "google-beta"
  depends_on = [ "google_project_service.compute" ]
  region = "${var.region["single"]}"
}



# Setting local variables for the sake of reusability of resouces described below
locals { 
  kubernetes_version = "1.13"
  instance-type      = "n1-standard-2"
}



# Create Kubernetes Cluster (Masters Only!)
resource "google_container_cluster" "kubernetes-cluster" {
  provider = "google-beta"
  depends_on = [
    "google_project_iam_member.kubernetes-service-account-editor",
    "google_service_account.kubernetes-service-account",
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

  network = "${var.compute_network}"
  subnetwork = "${google_compute_subnetwork.vpc_subnet_kubernetes.name}"
  ip_allocation_policy {
    cluster_secondary_range_name = "kubernetes-pods"
    services_secondary_range_name = "kubernetes-services"
  }
 
  initial_node_count = 1
  remove_default_node_pool = true

  node_config {
    tags = ["kubernetes"]
    preemptible  = true
    machine_type = "${local.instance-type}"
    disk_size_gb = 50
    oauth_scopes = [
      "cloud-platform"
    ]
    service_account = "${google_service_account.kubernetes-service-account.email}"
    labels = {
      "cloud.google.com/gke-preemptible"   = "true"
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
    http_load_balancing {
      disabled   = false
    }
    kubernetes_dashboard {
      disabled   = false
    }
    horizontal_pod_autoscaling {
      disabled   = false
    }
    istio_config {
      disabled   = false
      auth       = "AUTH_NONE"
    }
  }

  vertical_pod_autoscaling {
    enabled      = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  lifecycle {
    ignore_changes = [
      node_version,
      node_locations,
      node_pool,
    ]
  }
}


# Create Kubernetes Node Pool
resource "google_container_node_pool" "node-pool-a" {
  provider = "google-beta"
  depends_on = [
    "google_project_iam_member.kubernetes-service-account-editor",
    "google_service_account.kubernetes-service-account",
    "google_container_cluster.kubernetes-cluster",
    "google_project_service.container",
    "google_compute_subnetwork.vpc_subnet_kubernetes",
    "data.google_compute_zones.available"
  ]

  cluster      = "${google_container_cluster.kubernetes-cluster.name}"
  name         = "k8s-node-pool-${local.instance-type}-a"
  location     = "${var.region["single"]}"

  version = "${local.kubernetes_version}"

  initial_node_count = 1

  node_config {
    tags = ["kubernetes"]
    preemptible  = true
    machine_type = "${local.instance-type}"
    disk_size_gb = 50
    oauth_scopes = [
      "cloud-platform"
    ]
    service_account = "${google_service_account.kubernetes-service-account.email}"
    labels = {
      "cloud.google.com/gke-preemptible" = "true"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 10
  }

  management {
    auto_repair    = true
    auto_upgrade   = true 
  }

  lifecycle {
    ignore_changes = [
      version
    ]
  }
}
