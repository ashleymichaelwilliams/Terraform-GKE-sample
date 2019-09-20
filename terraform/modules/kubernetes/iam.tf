# Module: kubernetes/
# File: iam.tf



resource "google_service_account" "kubernetes-service-account" {
  project      = "${var.google_project}"
  account_id   = "gke-service-account"
  display_name = "Kubernetes Service Account"
}



resource "google_project_iam_member" "kubernetes-service-account-editor" {
  depends_on = [
    "google_service_account.kubernetes-service-account"
  ]
  project   = "${var.google_project}"
  role      = "roles/editor"
  member    =  "serviceAccount:${google_service_account.kubernetes-service-account.email}"
}

