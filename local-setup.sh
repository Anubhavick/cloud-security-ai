#!/bin/bash
# ============================================================================
# Local Development Setup Script
# ============================================================================
# This script helps you get started with local development
# Run: bash local-setup.sh
# ============================================================================

set -e  # Exit on error

echo "================================"
echo "Cloud Security AI - Local Setup"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓${NC} Python 3 found: $PYTHON_VERSION"
else
    echo -e "${RED}✗${NC} Python 3 not found"
    echo "  Install with: brew install python3"
    exit 1
fi

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js found: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found"
    echo "  Install with: brew install node"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm found: v$NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm not found"
    exit 1
fi

echo ""
echo "================================"
echo "Setting up backend..."
echo "================================"
echo ""

# Backend setup
cd backend

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✓${NC} Created backend/.env"
else
    echo -e "${YELLOW}⚠${NC} backend/.env already exists (skipping)"
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo -e "${GREEN}✓${NC} Virtual environment created"
else
    echo -e "${YELLOW}⚠${NC} Virtual environment already exists (skipping)"
fi

# Activate virtual environment and install dependencies
echo "Installing Python dependencies in virtual environment..."
source venv/bin/activate
pip install -r requirements.txt --quiet --disable-pip-version-check
echo -e "${GREEN}✓${NC} Python dependencies installed"

# Train model
echo "Training ML model..."
python train.py
echo -e "${GREEN}✓${NC} ML model trained"

deactivate
cd ..

echo ""
echo "================================"
echo "Setting up frontend..."
echo "================================"
echo ""

# Frontend setup
cd frontend

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✓${NC} Created frontend/.env"
else
    echo -e "${YELLOW}⚠${NC} frontend/.env already exists (skipping)"
fi

# Install npm dependencies
echo "Installing npm dependencies..."
npm install --silent
echo -e "${GREEN}✓${NC} npm dependencies installed"

cd ..

echo ""
echo "================================"
echo "✅ Local setup complete!"
echo "================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Start the backend (in terminal 1):"
echo "   ${GREEN}cd backend${NC}"
echo "   ${GREEN}source venv/bin/activate${NC}"
echo "   ${GREEN}python main.py${NC}"
echo "   ${GREEN}# OR use: make run-backend${NC}"
echo ""
echo "2. Start the frontend (in terminal 2):"
echo "   ${GREEN}cd frontend && npm run dev${NC}"
echo "   ${GREEN}# OR use: make run-frontend${NC}"
echo ""
echo "3. Open your browser:"
echo "   Frontend: ${GREEN}http://localhost:5173${NC}"
echo "   Backend API: ${GREEN}http://localhost:8000${NC}"
echo "   API Docs: ${GREEN}http://localhost:8000/docs${NC}"
echo ""
echo "4. (Optional) To deploy to OCI later:"
echo "   - Install OCI CLI: ${GREEN}brew install oci-cli${NC}"
echo "   - Configure: ${GREEN}oci setup config${NC}"
echo "   - Generate SSH key: ${GREEN}ssh-keygen -t rsa -b 4096 -f ~/.ssh/hackathon_key${NC}"
echo "   - Update ${GREEN}infra/terraform.tfvars${NC} with your tenancy_ocid and ssh_public_key"
echo "   - Run: ${GREEN}make init && make plan && make apply${NC}"
echo ""
echo "Happy hacking! 🚀"
