# Terraform-GKE-sample

#### This automation builds out a highly available Kubernetes cluster with three n1-standard-2 nodes (Spec: 2x CPUs and 7.5GB Memory for approx $.02/hr).
#### Each availability zone initially has one Preemptible instance (aka Spot instances) which will auto-scale depending on your scheduled workload needs.

<br>

##### Pricing Reference: https://cloud.google.com/compute/vm-instance-pricing#n1_predefined

<br>

##### Commands below have been tested and known to work on CentOS7 operating system

```
# Install Custom YUM Repository for Google Cloud SDK
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM


# Installs the Google Cloud SDK package
yum install google-cloud-sdk


# Authenticate to Google Cloud in active terminal shell
gcloud auth application-default login


# Set Environment Variables
PROJECT_NAME='test-gke-proj-001'
BILLING_ACCOUNT='123456-123456-123456'
GCS_BUCKET='my_gcs_bucket_name'


## NOTE: You will need to rename the terraform.tfvars file and replace the Billing Account example value with your Billing Account.
cp terraform/terraform.tfvars.json.sample terraform/terraform.tfvars.json
sed -i "s/123456-123456-123456/$BILLING_ACCOUNT/" terraform/terraform.tfvars.json


## NOTE: Run the following commands synchronously allowing them to complete, as you might experience a race-condition behavior otherwise.

# GCP Project Creation, Billing and API Library
gcloud projects create $PROJECT_NAME --name=$PROJECT_NAME
gcloud alpha billing projects link $PROJECT_NAME --billing-account=$BILLING_ACCOUNT
gcloud --project=$PROJECT_NAME services enable compute.googleapis.com

# Change your path to the Terraform Environment directory within the project repository
cd terraform/env-dev-us-central1

# Create Terraform Workspace, Init, Import and Apply
terraform workspace new $PROJECT_NAME
terraform init -backend-config="bucket=$GCS_BUCKET"
terraform import google_project.project $PROJECT_NAME
terraform apply -auto-approve
```
