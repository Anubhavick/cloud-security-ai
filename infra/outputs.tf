# ============================================================================
# Terraform Outputs
# ============================================================================
# These outputs display important information after terraform apply
# Use these values to connect to resources or configure other components
# ============================================================================

# ----------------------------------------------------------------------------
# Compartment Outputs
# ----------------------------------------------------------------------------

output "compartment_id" {
  description = "OCID of the created compartment"
  value       = oci_identity_compartment.hackathon_compartment.id
}

output "compartment_name" {
  description = "Name of the created compartment"
  value       = oci_identity_compartment.hackathon_compartment.name
}

# ----------------------------------------------------------------------------
# Networking Outputs
# ----------------------------------------------------------------------------

output "vcn_id" {
  description = "OCID of the Virtual Cloud Network"
  value       = oci_core_vcn.hackathon_vcn.id
}

output "vcn_cidr_block" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.hackathon_vcn.cidr_blocks[0]
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.hackathon_public_subnet.id
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = oci_core_subnet.hackathon_public_subnet.cidr_block
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.hackathon_igw.id
}

# ----------------------------------------------------------------------------
# Object Storage Outputs
# ----------------------------------------------------------------------------

output "bucket_name" {
  description = "Name of the Object Storage bucket"
  value       = oci_objectstorage_bucket.hackathon_bucket.name
}

output "bucket_namespace" {
  description = "Object Storage namespace"
  value       = data.oci_objectstorage_namespace.namespace.namespace
}

output "bucket_url" {
  description = "URL to access the bucket in OCI Console"
  value       = "https://cloud.oracle.com/object-storage/buckets/${data.oci_objectstorage_namespace.namespace.namespace}/${oci_objectstorage_bucket.hackathon_bucket.name}"
}

# ----------------------------------------------------------------------------
# Compute Instance Outputs
# ----------------------------------------------------------------------------

output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.hackathon_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the compute instance (use this to SSH and access the backend)"
  value       = oci_core_instance.hackathon_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the compute instance"
  value       = oci_core_instance.hackathon_instance.private_ip
}

output "instance_state" {
  description = "Current state of the compute instance"
  value       = oci_core_instance.hackathon_instance.state
}

# ----------------------------------------------------------------------------
# Connection Information
# ----------------------------------------------------------------------------

output "ssh_connection_command" {
  description = "SSH command to connect to the instance (replace with your private key path)"
  value       = "ssh -i ~/.ssh/hackathon_key opc@${oci_core_instance.hackathon_instance.public_ip}"
}

output "backend_api_url" {
  description = "Backend API URL (after deploying the FastAPI app on the instance)"
  value       = "http://${oci_core_instance.hackathon_instance.public_ip}:8000"
}

# ----------------------------------------------------------------------------
# Summary Output
# ----------------------------------------------------------------------------

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    compartment_name  = oci_identity_compartment.hackathon_compartment.name
    compartment_id    = oci_identity_compartment.hackathon_compartment.id
    vcn_name          = oci_core_vcn.hackathon_vcn.display_name
    subnet_name       = oci_core_subnet.hackathon_public_subnet.display_name
    bucket_name       = oci_objectstorage_bucket.hackathon_bucket.name
    instance_name     = oci_core_instance.hackathon_instance.display_name
    instance_ip       = oci_core_instance.hackathon_instance.public_ip
    ssh_command       = "ssh -i ~/.ssh/hackathon_key opc@${oci_core_instance.hackathon_instance.public_ip}"
    api_url           = "http://${oci_core_instance.hackathon_instance.public_ip}:8000"
  }
}
