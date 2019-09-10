### Main File: terraform.tf



### Load TF Storage Backend

terraform {
  backend "gcs" {
#    bucket = "gcs_bucket_name"
    prefix = "terraform/state"
  }
}



### Load TF Providers

provider "google" {
   project = "${terraform.workspace}" 
   version     = "2.14"
}

provider "google-beta" {
   project = "${terraform.workspace}"
   version     = "2.14"
}

provider "http" {
   version     = "1.1.1"
}



### Load GCP Project Resource

# Declare Variables for Project Resource
variable "billing_account" {}
variable "org_id" {}

# Declare Project Resource (as it needs to be imported!)
resource "google_project" "project" {
  name                  = "${terraform.workspace}"
  project_id            = "${terraform.workspace}"
  billing_account       = "${var.billing_account}"
}



### Load Terraform Modules

# Google Cloud Platform Project Module
module "project" {
  source = "../modules/project"
}

# Google VPC Networking Module
module "vpc-networking" {
  source = "../modules/vpc-networking"
}

# Google Kubernetes Engine Module
module "kubernetes" {
  source = "../modules/kubernetes"
  region = "${var.region}"
  compute_network = "${module.vpc-networking.compute_network}"
}
