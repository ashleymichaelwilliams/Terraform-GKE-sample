### Main File: terraform.tf


### Load Terraform's GCS Storage Backend

terraform {
  backend "gcs" {
    prefix = "terraform/state"
# The GCS Bucket name is handled by a variable
# Uncomment if you want to statically set this value
#   bucket = "gcs_bucket_name"
  }
}



### Load Terraform's Google Providers

provider "google" {
   project  = "${terraform.workspace}" 
   version  = "2.14"
}

provider "google-beta" {
   project  = "${terraform.workspace}"
   version  = "2.14"
}


### Load Misc Terraform's Providers

provider "http" {
   version  = "1.1.1"
}



### Declare Variables for Project Resource
variable "billing_account" {}
variable "org_id" {}



### Load Terraform Modules

# Google Cloud Platform Project Module
module "project" {
  source          = "../modules/project"
  billing_account = "${var.billing_account}"
  org_id          = "${var.org_id}"
}

# Google VPC Networking Module
module "vpc-networking" {
  source          = "../modules/vpc-networking"
  google_project  = "${module.project.google_project}"
}

# Google Kubernetes Engine Module
module "kubernetes" {
  source          = "../modules/kubernetes"
  google_project  = "${module.project.google_project}"
  region          = "${var.region}"
  compute_network = "${module.vpc-networking.compute_network}"
}
