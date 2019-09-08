# Terraform-GKE-sample

#### This automation builds out a highly available Kubernetes cluster with three n1-standard-2 nodes (Spec: 2x CPUs and 7.5GB Memory for approx $.02/hr).
#### Each availability zone initially has one Preemptible instance (aka Spot instances) which will auto-scale depending on your scheduled workload needs.

<br>

##### Pricing Reference: https://cloud.google.com/compute/vm-instance-pricing#n1_predefined

<br>

```
# Set Variables
PROJECT_NAME='Test-Proj-001'
BILLING_ACCOUNT='123456-123456-123456'

# GCP Project Creation, Billing and API Library
gcloud projects create $PROJECT_NAME --name=$PROJECT_NAME
gcloud alpha billing projects link $PROJECT_NAME --billing-account=$BILLING_ACCOUNT
gcloud --project=$PROJECT_NAME services enable compute.googleapis.com

# Create Terraform Workspace, Init, Import and Apply
terraform workspace new $PROJECT_NAME
terraform init
terraform import google_project.project $PROJECT_NAME
terraform apply -auto-approve
```

