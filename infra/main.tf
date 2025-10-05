# ============================================================================
# Main Terraform Configuration
# ============================================================================
# This file defines all the OCI resources needed for the hackathon project:
# - Compartment (for organizing resources)
# - VCN with public subnet, Internet Gateway, and routing
# - Object Storage bucket (for ML models/data)
# - Compute instance (for backend deployment)
# ============================================================================

# ----------------------------------------------------------------------------
# Data Sources
# ----------------------------------------------------------------------------

# Get the availability domains in the region
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get the latest Oracle Linux 8 image if no specific image_id is provided
data "oci_core_images" "oracle_linux_8" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ----------------------------------------------------------------------------
# Compartment
# ----------------------------------------------------------------------------

# Create a dedicated compartment for this hackathon project
# This helps organize and isolate resources
resource "oci_identity_compartment" "hackathon_compartment" {
  compartment_id = var.tenancy_ocid  # Parent is the tenancy (root compartment)
  name           = var.compartment_name
  description    = var.compartment_description
  
  # Enable delete on destroy (useful for hackathons/testing)
  enable_delete = true

  freeform_tags = {
    "Project" = var.project_tag
  }
}

# ----------------------------------------------------------------------------
# Networking - VCN, Subnet, Internet Gateway, Route Table
# ----------------------------------------------------------------------------

# Create a Virtual Cloud Network (VCN)
# This is your isolated network in OCI
resource "oci_core_vcn" "hackathon_vcn" {
  compartment_id = oci_identity_compartment.hackathon_compartment.id
  
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = var.vcn_display_name
  dns_label      = "hackathonvcn"  # DNS label for internal DNS
  
  freeform_tags = {
    "Project" = var.project_tag
  }
}

# Create an Internet Gateway
# This allows resources in the VCN to communicate with the internet
resource "oci_core_internet_gateway" "hackathon_igw" {
  compartment_id = oci_identity_compartment.hackathon_compartment.id
  vcn_id         = oci_core_vcn.hackathon_vcn.id
  
  display_name = "${var.vcn_display_name}-igw"
  enabled      = true
  
  freeform_tags = {
    "Project" = var.project_tag
  }
}

# Create a Route Table for the public subnet
# Routes all internet-bound traffic through the Internet Gateway
resource "oci_core_route_table" "hackathon_public_route_table" {
  compartment_id = oci_identity_compartment.hackathon_compartment.id
  vcn_id         = oci_core_vcn.hackathon_vcn.id
  
  display_name = "${var.vcn_display_name}-public-rt"
  
  # Route all internet traffic (0.0.0.0/0) through the Internet Gateway
  route_rules {
    network_entity_id = oci_core_internet_gateway.hackathon_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  
  freeform_tags = {
    "Project" = var.project_tag
  }
}

# Create a Security List for the public subnet
# This acts as a virtual firewall for the subnet
resource "oci_core_security_list" "hackathon_public_security_list" {
  compartment_id = oci_identity_compartment.hackathon_compartment.id
  vcn_id         = oci_core_vcn.hackathon_vcn.id
  
  display_name = "${var.vcn_display_name}-public-sl"
  
  # Egress Rules (outbound traffic)
  # Allow all outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }
  
  # Ingress Rules (inbound traffic)
  
  # Allow SSH (port 22) from anywhere
  # NOTE: In production, restrict this to your IP address
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    description = "Allow SSH"
    
    tcp_options {
      min = 22
      max = 22
    }
  }
  
  # Allow HTTP (port 80) from anywhere
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    description = "Allow HTTP"
    
    tcp_options {
      min = 80
      max = 80
    }
  }
  
  # Allow HTTPS (port 443) from anywhere
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    description = "Allow HTTPS"
    
    tcp_options {
      min = 443
      max = 443
    }
  }
  
  # Allow FastAPI/backend (port 8000) from anywhere
  # NOTE: In production, use a reverse proxy or restrict access
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    description = "Allow FastAPI backend"
    
    tcp_options {
      min = 8000
      max = 8000
    }
  }
  
  # Allow ICMP (ping) for troubleshooting
  ingress_security_rules {
    protocol    = "1"  # ICMP
    source      = "0.0.0.0/0"
    description = "Allow ICMP (ping)"
  }
  
  freeform_tags = {
    "Project" = var.project_tag
  }
}

# Create a public subnet
# This subnet has access to the internet through the Internet Gateway
resource "oci_core_subnet" "hackathon_public_subnet" {
  compartment_id    = oci_identity_compartment.hackathon_compartment.id
  vcn_id            = oci_core_vcn.hackathon_vcn.id
  cidr_block        = var.subnet_cidr_block
  
  display_name      = "${var.vcn_display_name}-public-subnet"
  dns_label         = "public"
  
  # Associate with the route table and security list
  route_table_id    = oci_core_route_table.hackathon_public_route_table.id
  security_list_ids = [oci_core_security_list.hackathon_public_security_list.id]
  
  # This is a public subnet - instances will get public IPs
  prohibit_public_ip_on_vnic = false
  
  freeform_tags = {
    "Project" = var.project_tag
  }
}

# ----------------------------------------------------------------------------
# Object Storage
# ----------------------------------------------------------------------------

# Create an Object Storage bucket
# Use this to store ML models, datasets, logs, etc.
resource "oci_objectstorage_bucket" "hackathon_bucket" {
  compartment_id = oci_identity_compartment.hackathon_compartment.id
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
  name           = var.bucket_name
  
  access_type    = var.bucket_access_type  # NoPublicAccess by default
  storage_tier   = "Standard"
  
  # Enable versioning (useful for ML model versioning)
  versioning = "Enabled"
  
  freeform_tags = {
    "Project" = var.project_tag
  }
}

# Get the Object Storage namespace for your tenancy
data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.tenancy_ocid
}

# ----------------------------------------------------------------------------
# Compute Instance
# ----------------------------------------------------------------------------

# Create a compute instance for deploying the backend
# Using Always Free tier shape (VM.Standard.E2.1.Micro)
resource "oci_core_instance" "hackathon_instance" {
  compartment_id      = oci_identity_compartment.hackathon_compartment.id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  display_name = var.instance_display_name
  shape        = var.instance_shape
  
  # For flexible shapes (not needed for Micro, but included for flexibility)
  # Uncomment if using a flexible shape like VM.Standard.E3.Flex or VM.Standard.A1.Flex
  # shape_config {
  #   ocpus         = var.instance_ocpus
  #   memory_in_gbs = var.instance_memory_in_gbs
  # }
  
  # Define the network configuration
  create_vnic_details {
    subnet_id        = oci_core_subnet.hackathon_public_subnet.id
    assign_public_ip = true  # Assign a public IP for SSH and API access
    display_name     = "${var.instance_display_name}-vnic"
    hostname_label   = "hackathonvm"
  }
  
  # Define the boot volume (OS disk)
  source_details {
    source_type             = "image"
    source_id               = var.instance_image_id != "" ? var.instance_image_id : data.oci_core_images.oracle_linux_8.images[0].id
    boot_volume_size_in_gbs = var.instance_boot_volume_size_in_gbs
  }
  
  # SSH key for accessing the instance
  metadata = var.ssh_public_key != "" ? {
    ssh_authorized_keys = var.ssh_public_key
    
    # Cloud-init script to set up the instance on first boot
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      project_tag = var.project_tag
    }))
  } : {
    # Cloud-init script to set up the instance on first boot
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      project_tag = var.project_tag
    }))
  }
  
  freeform_tags = {
    "Project" = var.project_tag
  }
  
  # Preserve boot volume on instance termination (useful for data persistence)
  preserve_boot_volume = false
}

# ----------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------
# These values will be displayed after terraform apply
# and can be referenced by other tools or scripts
