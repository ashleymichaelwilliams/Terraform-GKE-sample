# Module: env-dev-us-central1
# File: variables.tf
# Environmental variables specific for the 'dev-us' environment



variable "region" {
  type = "map"
  default = {
    "single" = "us-central1"
    "multi" = "US"
  }
}

