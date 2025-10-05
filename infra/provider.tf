# ============================================================================
# OCI Provider Configuration
# ============================================================================
# This file configures the Oracle Cloud Infrastructure (OCI) Terraform provider.
# It uses the DEFAULT profile from your ~/.oci/config file.
# Make sure you have run `oci setup config` before using this.
# ============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Configure the OCI Provider
# Uses the DEFAULT profile from ~/.oci/config
# This includes your user_ocid, fingerprint, private_key_path, tenancy_ocid, and region
provider "oci" {
  config_file_profile = "DEFAULT"
  region              = var.region
}
