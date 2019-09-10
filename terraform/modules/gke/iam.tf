# Module: gke
# File: iam.tf



resource "google_service_account" "kubernetes-service-account" {
  account_id   = "gke-service-account"
  display_name = "Kubernetes Service Account"
}


resource "google_project_iam_member" "kubernetes-service-account-editor" {
  depends_on = [
    "google_service_account.kubernetes-service-account"
  ]
  role      = "roles/editor"
  member    =  "serviceAccount:${google_service_account.kubernetes-service-account.email}"
}

