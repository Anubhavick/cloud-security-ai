# Quick Setup Guide

## Current Issues & Fixes

### 1. OCI CLI Not Configured ⚠️

**Error:** `open /Users/anubhavick/.oci/config: no such file or directory`

**Fix:**
```bash
# Install OCI CLI (if not installed)
brew install oci-cli

# Configure OCI CLI
oci setup config
```

You'll be asked for:
- **Location for config:** Press Enter (default: `~/.oci/config`)
- **User OCID:** Get from OCI Console → Profile → User Settings
- **Tenancy OCID:** Get from OCI Console → Profile → Tenancy
- **Region:** e.g., `us-ashburn-1`, `us-phoenix-1`
- **Generate new RSA key pair:** Y (yes)
- **Key location:** Press Enter (default)
- **Passphrase:** Leave empty for hackathon

After setup, add the API key to OCI Console:
1. Copy the public key: `cat ~/.oci/oci_api_key_public.pem`
2. Go to OCI Console → Profile → User Settings → API Keys → Add API Key
3. Paste the public key

### 2. Python Not Found ⚠️

**Error:** `zsh: command not found: python`

**Fix:**
```bash
# Install Python 3
brew install python3

# Verify installation
python3 --version

# Install pip packages
cd backend
python3 -m pip install -r requirements.txt
```

### 3. PostCSS Config Error (FIXED) ✅

The `postcss.config.js` has been fixed to use ES module syntax.

### 4. SSH Key (Optional for now) ✅

SSH key is now optional. You can deploy infrastructure without it and add it later if needed.

---

## Step-by-Step Setup (macOS)

### Prerequisites

```bash
# 1. Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install required tools
brew install terraform
brew install oci-cli
brew install python3
brew install node

# 3. Verify installations
terraform --version
oci --version
python3 --version
node --version
npm --version
```

### OCI Setup

```bash
# 1. Configure OCI CLI
oci setup config

# 2. Add API key to OCI Console
cat ~/.oci/oci_api_key_public.pem
# Copy output and add to OCI Console → Profile → API Keys

# 3. Test OCI connection
oci iam region list
```

### Generate SSH Key (Optional but Recommended)

```bash
# Generate SSH key for compute instance access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/hackathon_key

# View public key
cat ~/.ssh/hackathon_key.pub
```

### Configure Terraform

```bash
cd infra

# Copy and edit terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # or use any editor
```

Fill in:
```hcl
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaxxxx"  # From OCI Console
ssh_public_key = "ssh-rsa AAAAB3NzaC1..."      # Optional: from ~/.ssh/hackathon_key.pub
region = "us-ashburn-1"                         # Your region
```

### Deploy Infrastructure

```bash
# From project root
make init    # Initialize Terraform
make plan    # Review changes
make apply   # Create resources (type 'yes')
```

### Run Backend

```bash
# Install dependencies
cd backend
python3 -m pip install -r requirements.txt

# Train model
python3 train.py

# Run backend
python3 main.py

# Or use Makefile
make run-backend
```

Backend will run at: `http://localhost:8000`

### Run Frontend

```bash
# Install dependencies
cd frontend
npm install

# Copy environment file
cp .env.example .env

# Run frontend
npm run dev

# Or use Makefile
make run-frontend
```

Frontend will run at: `http://localhost:5173`

---

## Quick Commands

```bash
# Setup everything (after installing prerequisites)
make setup-dev

# Run backend (in terminal 1)
make run-backend

# Run frontend (in terminal 2)
make run-frontend

# Deploy infrastructure
make init
make plan
make apply

# Clean everything
make clean
```

---

## Troubleshooting

### "python: command not found"
Use `python3` instead of `python` on macOS.

### "pip: command not found"
Use `python3 -m pip` instead of `pip`.

### "terraform plan fails with 401-NotAuthenticated"
Run `oci setup config` and add API key to OCI Console.

### "npm run dev fails"
The PostCSS config has been fixed. Try:
```bash
cd frontend
rm -rf node_modules
npm install
npm run dev
```

### "Can't SSH to instance"
1. Make sure you added `ssh_public_key` to `terraform.tfvars`
2. Run `terraform apply` again to update the instance
3. Check key permissions: `chmod 400 ~/.ssh/hackathon_key`

---

## What's Next?

1. ✅ Fix OCI CLI setup
2. ✅ Install Python 3
3. ✅ Get infrastructure running locally
4. 🚀 Focus on your ML model and features
5. 🎯 Prepare for hackathon demo!

**Note:** You can work on the application locally first and deploy to OCI later. The backend and frontend work perfectly on localhost.
