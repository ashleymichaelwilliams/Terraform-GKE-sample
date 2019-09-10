# Module: vpc-networking/
# File: outputs.tf



output "compute_network" {
  value = "${google_compute_network.vpc-network.name}"
}
