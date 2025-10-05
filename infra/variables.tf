# ============================================================================
# Terraform Variables
# ============================================================================
# Define all input variables for the infrastructure.
# Override these values in terraform.tfvars file.
# ============================================================================

# ----------------------------------------------------------------------------
# General Configuration
# ----------------------------------------------------------------------------

variable "region" {
  description = "OCI region where resources will be created (e.g., us-ashburn-1, us-phoenix-1)"
  type        = string
  default     = "us-ashburn-1"
}

variable "tenancy_ocid" {
  description = "OCID of your OCI tenancy. Find this in OCI Console -> User menu -> Tenancy"
  type        = string
  # This MUST be filled in terraform.tfvars
}

# ----------------------------------------------------------------------------
# Compartment Configuration
# ----------------------------------------------------------------------------

variable "compartment_name" {
  description = "Name of the compartment to create for this hackathon project"
  type        = string
  default     = "hackathon-cloud-security-ai"
}

variable "compartment_description" {
  description = "Description for the compartment"
  type        = string
  default     = "Compartment for Oracle Hackathon - AI/ML Cloud Security Project"
}

# ----------------------------------------------------------------------------
# Networking Configuration
# ----------------------------------------------------------------------------

variable "vcn_cidr_block" {
  description = "CIDR block for the Virtual Cloud Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vcn_display_name" {
  description = "Display name for the VCN"
  type        = string
  default     = "hackathon-vcn"
}

# ----------------------------------------------------------------------------
# Object Storage Configuration
# ----------------------------------------------------------------------------

variable "bucket_name" {
  description = "Name of the Object Storage bucket for ML models and data"
  type        = string
  default     = "hackathon-ml-bucket"
}

variable "bucket_access_type" {
  description = "Access type for the bucket (NoPublicAccess or ObjectRead)"
  type        = string
  default     = "NoPublicAccess"
}

# ----------------------------------------------------------------------------
# Compute Instance Configuration
# ----------------------------------------------------------------------------

variable "instance_display_name" {
  description = "Display name for the compute instance"
  type        = string
  default     = "hackathon-backend-vm"
}

variable "instance_shape" {
  description = "Shape of the compute instance (VM.Standard.E2.1.Micro is Always Free tier)"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_ocpus" {
  description = "Number of OCPUs for flexible shapes (not used for Micro shape)"
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory in GBs for flexible shapes (not used for Micro shape)"
  type        = number
  default     = 6
}

variable "instance_boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GBs"
  type        = number
  default     = 50
}

variable "instance_image_id" {
  description = "OCID of the OS image. Leave empty to use latest Oracle Linux 8. Find images: oci compute image list"
  type        = string
  default     = ""
  # If empty, we'll use a data source to find the latest Oracle Linux 8 image
}

variable "ssh_public_key" {
  description = "SSH public key to access the compute instance. Generate with: ssh-keygen -t rsa -b 4096"
  type        = string
  default     = ""
  # This MUST be filled in terraform.tfvars for SSH access
  # Example: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD..."
}

# ----------------------------------------------------------------------------
# Tagging
# ----------------------------------------------------------------------------

variable "project_tag" {
  description = "Tag to identify resources for this project"
  type        = string
  default     = "oracle-hackathon-2025"
}
