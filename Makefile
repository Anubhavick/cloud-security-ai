# ============================================================================
# Makefile for Cloud Security AI - Oracle Hackathon Project
# ============================================================================
# Convenient commands to manage infrastructure and applications
# ============================================================================

.PHONY: help init plan apply destroy run-backend run-frontend build-frontend ssh-vm clean

# Default target
help:
	@echo "Cloud Security AI - Oracle Hackathon Makefile"
	@echo ""
	@echo "Available commands:"
	@echo "  make help              - Show this help message"
	@echo ""
	@echo "Quick Start:"
	@echo "  make setup-dev         - Setup complete dev environment"
	@echo "  make docker-up         - Start all services with Docker"
	@echo "  make docker-down       - Stop Docker services"
	@echo ""
	@echo "Infrastructure (Terraform):"
	@echo "  make init              - Initialize Terraform"
	@echo "  make plan              - Show Terraform execution plan"
	@echo "  make apply             - Apply Terraform configuration (create resources)"
	@echo "  make destroy           - Destroy all Terraform resources"
	@echo "  make output            - Show Terraform outputs"
	@echo ""
	@echo "Backend (FastAPI):"
	@echo "  make run-backend       - Run backend locally"
	@echo "  make train-model       - Train ML model"
	@echo "  make test-backend      - Test backend API"
	@echo ""
	@echo "Frontend (React):"
	@echo "  make run-frontend      - Run frontend locally"
	@echo "  make build-frontend    - Build frontend for production"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build      - Build Docker images"
	@echo "  make docker-up         - Start services with Docker Compose"
	@echo "  make docker-down       - Stop Docker services"
	@echo "  make docker-logs       - View Docker logs"
	@echo "  make docker-clean      - Clean Docker containers and images"
	@echo ""
	@echo "Deployment:"
	@echo "  make ssh-vm            - SSH into OCI compute instance"
	@echo "  make deploy-backend    - Deploy backend to OCI instance"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean             - Clean build artifacts"

# ============================================================================
# Terraform Commands
# ============================================================================

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	cd infra && terraform init

# Plan infrastructure changes
plan:
	@echo "Planning Terraform changes..."
	cd infra && terraform plan

# Apply infrastructure changes
apply:
	@echo "Applying Terraform configuration..."
	@echo "This will create resources in OCI. Continue? [y/N]"
	@read -r REPLY; \
	if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
		cd infra && terraform apply; \
	else \
		echo "Aborted."; \
	fi

# Destroy infrastructure
destroy:
	@echo "WARNING: This will destroy all resources!"
	@echo "Are you sure? Type 'yes' to confirm:"
	@read -r REPLY; \
	if [ "$$REPLY" = "yes" ]; then \
		cd infra && terraform destroy; \
	else \
		echo "Aborted."; \
	fi

# Show Terraform outputs
output:
	@echo "Terraform outputs:"
	cd infra && terraform output

# ============================================================================
# Backend Commands
# ============================================================================

# Run backend locally
run-backend:
	@echo "Starting FastAPI backend..."
	@if [ -d "backend/venv" ]; then \
		cd backend && source venv/bin/activate && python main.py; \
	else \
		echo "Virtual environment not found. Run 'make setup-dev' first or:"; \
		echo "  cd backend && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt"; \
	fi

# Train ML model
train-model:
	@echo "Training ML model..."
	@if [ -d "backend/venv" ]; then \
		cd backend && source venv/bin/activate && python train.py; \
	else \
		echo "Virtual environment not found. Run 'make setup-dev' first."; \
	fi

# Test backend API
test-backend:
	@echo "Testing backend API..."
	@curl -s http://localhost:8000/health | jq '.' || echo "Backend not running or jq not installed"

# ============================================================================
# Frontend Commands
# ============================================================================

# Install frontend dependencies
install-frontend:
	@echo "Installing frontend dependencies..."
	cd frontend && npm install

# Run frontend locally
run-frontend: install-frontend
	@echo "Starting React frontend..."
	cd frontend && npm run dev

# Build frontend for production
build-frontend: install-frontend
	@echo "Building frontend for production..."
	cd frontend && npm run build

# ============================================================================
# Deployment Commands
# ============================================================================

# SSH into OCI compute instance
ssh-vm:
	@echo "Connecting to OCI instance..."
	@INSTANCE_IP=$$(cd infra && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$INSTANCE_IP" ]; then \
		echo "Error: Could not get instance IP. Run 'make apply' first."; \
		exit 1; \
	fi; \
	echo "SSH to: opc@$$INSTANCE_IP"; \
	ssh -i ~/.ssh/hackathon_key opc@$$INSTANCE_IP

# Deploy backend to OCI instance
deploy-backend:
	@echo "Deploying backend to OCI instance..."
	@INSTANCE_IP=$$(cd infra && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$INSTANCE_IP" ]; then \
		echo "Error: Could not get instance IP. Run 'make apply' first."; \
		exit 1; \
	fi; \
	echo "Copying backend files to opc@$$INSTANCE_IP:/opt/hackathon/"; \
	ssh -i ~/.ssh/hackathon_key opc@$$INSTANCE_IP "mkdir -p /opt/hackathon"; \
	scp -i ~/.ssh/hackathon_key -r backend/* opc@$$INSTANCE_IP:/opt/hackathon/; \
	echo "Building and running Docker container..."; \
	ssh -i ~/.ssh/hackathon_key opc@$$INSTANCE_IP "cd /opt/hackathon && docker build -t backend . && docker stop backend || true && docker rm backend || true && docker run -d -p 8000:8000 --name backend --restart unless-stopped backend"; \
	echo "Backend deployed! Access at: http://$$INSTANCE_IP:8000"

# ============================================================================
# Docker Commands
# ============================================================================

# Build Docker images
docker-build:
	@echo "Building Docker images..."
	docker-compose build

# Start services with Docker Compose
docker-up:
	@echo "Starting services with Docker Compose..."
	@echo "This will train the ML model and start both backend and frontend"
	@if [ ! -f "backend/app/ml_models/model.joblib" ]; then \
		echo "Training ML model first..."; \
		cd backend && python3 train.py || true; \
	fi
	docker-compose up -d
	@echo ""
	@echo "Services started!"
	@echo "Frontend: http://localhost"
	@echo "Backend: http://localhost:8000"
	@echo "API Docs: http://localhost:8000/docs"
	@echo ""
	@echo "View logs: make docker-logs"
	@echo "Stop: make docker-down"

# Stop Docker services
docker-down:
	@echo "Stopping Docker services..."
	docker-compose down

# View Docker logs
docker-logs:
	@echo "Viewing Docker logs (Ctrl+C to exit)..."
	docker-compose logs -f

# Restart Docker services
docker-restart:
	@echo "Restarting Docker services..."
	docker-compose restart

# Clean Docker containers and images
docker-clean:
	@echo "Cleaning Docker containers and images..."
	docker-compose down -v --rmi all
	@echo "Docker cleanup complete!"

# ============================================================================
# Cleanup Commands
# ============================================================================

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf backend/__pycache__
	rm -rf backend/app/__pycache__
	rm -rf backend/app/routers/__pycache__
	rm -rf backend/app/ml_models/__pycache__
	rm -rf backend/.pytest_cache
	rm -rf backend/data/*.csv
	rm -rf frontend/node_modules
	rm -rf frontend/dist
	rm -rf frontend/.vite
	@echo "Clean complete!"

# ============================================================================
# Development Setup
# ============================================================================

# Setup development environment
setup-dev:
	@echo "Setting up development environment..."
	@echo "1. Creating Python virtual environment..."
	cd backend && python3 -m venv venv
	@echo "2. Installing backend dependencies..."
	cd backend && source venv/bin/activate && pip install -r requirements.txt
	@echo "3. Installing frontend dependencies..."
	cd frontend && npm install
	@echo "4. Creating environment files..."
	cd backend && [ ! -f .env ] && cp .env.example .env || echo ".env already exists"
	cd frontend && [ ! -f .env ] && cp .env.example .env || echo ".env already exists"
	@echo "5. Training initial model..."
	cd backend && source venv/bin/activate && python train.py
	@echo ""
	@echo "Setup complete! Next steps:"
	@echo "1. Run 'make run-backend' in one terminal"
	@echo "2. Run 'make run-frontend' in another terminal"
	@echo "3. (Optional) Set up OCI CLI: oci setup config"
	@echo "4. (Optional) Generate SSH key: ssh-keygen -t rsa -b 4096 -f ~/.ssh/hackathon_key"
	@echo "5. (Optional) Configure infra/terraform.tfvars for OCI deployment"

# Quick start all services locally
dev: setup-dev
	@echo "Starting all services..."
	@echo "Run 'make run-backend' in one terminal and 'make run-frontend' in another"
