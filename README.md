# Terraform-GKE-sample

#### This Terraform automation builds out a highly available managed Kubernetes cluster running on Google's GKE service. <br> 
The cluster's node-pool is spread across 3x availability zones with *n1-standard-2* instance type preemptible nodes. <br> 

> n1-standard-2 Spec: 2x CPUs and 7.5GB Memory <br> 
Note: Approximate cost per preemptible instance is **$.02/hr** at the time of writing

#### Each availability zone will initially only have one instance each, which will auto-scale depending on your scheduled workload needs.


##### Pricing Reference: https://cloud.google.com/compute/vm-instance-pricing#n1_predefined

<br>

### Required Prerequisite Steps:

1. Obtain Google billing account ID for associating your provisioned projects to your billing account.
2. Have an available Google Storage Bucket (GCS) used for Terraform state data.
3. Installed the Terraform binary in your local operating system. (Instructions below for CentOS 7 and Mac OSX)

<br>

#### Prerequisite 1: Obtain Google billing account ID for associating your provisioned projects to your billing account

You will need to associate your newly provisioned projects to your Google billing account.

To obtain your billing account ID, navigate to: https://console.cloud.google.com/billing <br>
or via the gcloud SDK, by performing the following commands:
```bash
gcloud beta billing accounts list --filter=OPEN=true
```

Make a note of this billing account ID as you will need it in the later steps of these instructions.

<br>

#### Prerequisite 2: Have an available Google Storage Bucket (GCS) used for Terraform state data.

You will need to create a new GCS Bucket whinin a GCP project.

You can do this via the web console by navigating to: https://console.cloud.google.com/storage/create-bucket
or via the gcloud SDK, by performing the following commands:
```bash
# Set Environemtn Variables for Resource Names
TF_STATE_PROJECT_NAME='<MY_TF_STATE_PROJECT_NAME_GOES_HERE>'
TF_STATE_BUCKET_NAME='<MY_TF_STATE_BUCKET_NAME_GOES_HERE>'

# Creates the GCP Project
gcloud project create ${TF_STATE_PROJECT_NAME}

# Creates the GCS Bucket
gsutil mb -p ${TF_STATE_PROJECT_NAME} -l us gs://${TF_STATE_BUCKET_NAME}
```

<br>

#### Prerequisite 3: Installed the Terraform binary in your local operating system

If you haven't already, you will need to download and install the Terraform binary into your operating system.

You can do this by performing the following commands on the respective operating system:

##### The following commands below have been tested and known to work on CentOS 7 operating system
```bash
TF_VERSION=0.12.9

# Download/Extract Terraform Binary running on Linux
curl -s https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip --output terraform_${TF_VERSION}_linux_amd64.zip
unzip terraform_${TF_VERSION}_darwin_amd64.zip -d /usr/local/bin/
```

##### The following commands below have been tested and known to work on Mac OSX operating system
```bash
TF_VERSION=0.12.9

# Download/Extract Terraform Binary running on Mac OSX
curl -s https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_darwin_amd64.zip --output terraform_${TF_VERSION}_darwin_amd64.zip
unzip terraform_${TF_VERSION}_darwin_amd64.zip -d /usr/local/bin/
```

<br>

### Preparation

The following step is only initially required for the necessary tools as well as configuring your billing account id.

##### The following commands below have been tested and known to work on CentOS 7 operating system

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


## NOTE: You will need to copy or rename the terraform.tfvars.sample file and replace the Billing Account value with your Billing Account.

# Set Environment Variables
BILLING_ACCOUNT='123456-123456-123456'

cp terraform/terraform.tfvars.json.sample terraform/terraform.tfvars.json
sed -i "s/123456-123456-123456/$BILLING_ACCOUNT/" terraform/terraform.tfvars.json
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


## NOTE: You will need to copy or rename the terraform.tfvars.sample file and replace the Billing Account value with your Billing Account.

# Set Environment Variables
BILLING_ACCOUNT='123456-123456-123456'

cp terraform/terraform.tfvars.json.sample terraform/terraform.tfvars.json
sed -ie 's|123456-123456-123456|'"${BILLING_ACCOUNT}"'|g' terraform/terraform.tfvars.json
```

<br>

### Deployment

This is the only step that is needed once all of the above dependencies have been met...

```
# Change your path to the Terraform Environment directory within the project repository
cd terraform/env-dev-us-central1

# Set Environment Variables
PROJECT_NAME='test-gke-proj-001'
GCS_BUCKET='gcs_bucket_name'

# Create Terraform Workspace, Init, Import and Apply
terraform init -backend-config="bucket=$GCS_BUCKET"
terraform workspace new $PROJECT_NAME
terraform apply -auto-approve
```

