# Terraform-GKE-sample

#### This automation builds out a highly available Kubernetes cluster with three n1-standard-2 nodes (Spec: 2x CPUs and 7.5GB Memory for approx $.02/hr).
#### Each availability zone initially has one Preemptible instance (aka Spot instances) which will auto-scale depending on your scheduled workload needs.

<br>

##### Pricing Reference: https://cloud.google.com/compute/vm-instance-pricing#n1_predefined

<br>

##### The following commands below have been tested and known to work on CentOS7 operating system

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

# Installs the kubectl package
yum install kubectl


# Change directories to Git Project
cd ~/Repos/Terraform-GKE-sample

# Authenticate to Google Cloud in active terminal shell
gcloud auth login
gcloud auth application-default login


# Set Environment Variables
PROJECT_NAME='test-gke-proj-001'
BILLING_ACCOUNT='123456-123456-123456'
GCS_BUCKET='gcs_bucket_name'


## NOTE: You will need to copy or rename the terraform.tfvars.sample file and replace the Billing Account value with your Billing Account.
cp terraform/terraform.tfvars.json.sample terraform/terraform.tfvars.json

### Run this if using CentOS Linux
sed -i "s/123456-123456-123456/$BILLING_ACCOUNT/" terraform/terraform.tfvars.json


# Change your path to the Terraform Environment directory within the project repository
cd terraform/env-dev-us-central1

# Create Symbolic Link to Terraform Variables File
# ln -s ../terraform.tfvars.json terraform.tfvars.json # This is no longer necessary as we preserved the symbolic link in the git repository

# Create Terraform Workspace, Init, Import and Apply
terraform init -backend-config="bucket=$GCS_BUCKET"
terraform workspace new $PROJECT_NAME
terraform apply -auto-approve
```

<br>


##### The following commands below have been tested and known to work on Mac OSX operating system

```
# Set gcloud SDK Filename (which includes sdk version)
GCLOUD_SDK_FILENAME='google-cloud-sdk-263.0.0-darwin-x86_64'

# Download gcloud SDK and extract archive
cd ~/Downloads/
curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$GCLOUD_SDK_FILENAME.tar.gz --output $GCLOUD_SDK_FILENAME.tar.gz
gunzip -c $GCLOUD_SDK_FILENAME.tar.gz | tar xopf -

# Install gcloud SDK
cd ~/Downloads/google-cloud-sdk/
./install.sh -q --additional-components kubectl


# Change directories to Terraform-GKE Project Folder
cd ~/Repos/Terraform-GKE-sample

# Authenticate to Google Cloud in active terminal shell
gcloud auth login
gcloud auth application-default login


# Set Environment Variables
PROJECT_NAME='test-gke-proj-001'
BILLING_ACCOUNT='123456-123456-123456'
GCS_BUCKET='gcs_bucket_name'


## NOTE: You will need to copy or rename the terraform.tfvars.sample file and replace the Billing Account value with your Billing Account.
cp terraform/terraform.tfvars.json.sample terraform/terraform.tfvars.json

### Run this if using Mac OSX
sed -ie 's|123456-123456-123456|'"${BILLING_ACCOUNT}"'|g' terraform/terraform.tfvars.json


# Change your path to the Terraform Environment directory within the project repository
cd terraform/env-dev-us-central1

# Create Symbolic Link to Terraform Variables File
# ln -s ../terraform.tfvars.json terraform.tfvars.json # This is no longer necessary as we preserved the symbolic link in the git repository

# Create Terraform Workspace, Init, Import and Apply
terraform init -backend-config="bucket=$GCS_BUCKET"
terraform workspace new $PROJECT_NAME
terraform apply -auto-approve
```
