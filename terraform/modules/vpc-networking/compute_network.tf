# Module: vpc-networking
# File: compute_network.tf



resource "google_compute_network" "vpc-network" {
  name                    	= "vpc-network"
  project 			= "${terraform.workspace}"
  auto_create_subnetworks 	= "false"
}
