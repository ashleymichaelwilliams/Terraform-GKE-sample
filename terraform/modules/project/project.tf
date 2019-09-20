# Module: project/
# File: project.tf



# Declare Project Resource (as it needs to be imported!)
resource "google_project" "project" {
  name                  = "${terraform.workspace}"
  project_id            = "${terraform.workspace}"
  billing_account       = "${var.billing_account}"
  auto_create_network   = true
  skip_delete           = true
}

