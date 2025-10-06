#!/bin/bash
# ============================================================================
# Quick Setup Script - Cloud Security AI
# ============================================================================
# This script sets up the entire project with one command
# Usage: ./quick-setup.sh
# ============================================================================

set -e  # Exit on error

echo "=========================================="
echo "Cloud Security AI - Quick Setup"
echo "Oracle Hackathon 2025"
echo "=========================================="
echo ""

# Check if Docker is installed
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    echo "✅ Docker detected"
    USE_DOCKER=true
else
    echo "⚠️  Docker not found"
    USE_DOCKER=false
fi

# Ask user which setup method
if [ "$USE_DOCKER" = true ]; then
    echo ""
    echo "Choose setup method:"
    echo "1) Docker (Recommended - Easiest)"
    echo "2) Local Development (Python + Node.js required)"
    read -p "Enter choice [1/2]: " choice
    
    if [ "$choice" = "1" ]; then
        echo ""
        echo "=========================================="
        echo "Setting up with Docker..."
        echo "=========================================="
        
        # Train ML model
        echo ""
        echo "Step 1/3: Training ML model..."
        cd backend
        if command -v python3 &> /dev/null; then
            python3 train.py
        elif command -v python &> /dev/null; then
            python train.py
        else
            echo "⚠️  Python not found. Please train model manually:"
            echo "    cd backend && python3 train.py"
        fi
        cd ..
        
        # Build Docker images
        echo ""
        echo "Step 2/3: Building Docker images..."
        docker-compose build
        
        # Start services
        echo ""
        echo "Step 3/3: Starting services..."
        docker-compose up -d
        
        echo ""
        echo "=========================================="
        echo " Setup Complete!"
        echo "=========================================="
        echo ""
        echo "🌐 Frontend: http://localhost"
        echo "🔧 Backend: http://localhost:8000"
        echo "📚 API Docs: http://localhost:8000/docs"
        echo ""
        echo "Useful commands:"
        echo "  make docker-logs    - View logs"
        echo "  make docker-down    - Stop services"
        echo "  make docker-restart - Restart services"
        echo ""
        exit 0
    fi
fi

# Local development setup
echo ""
echo "=========================================="
echo "Setting up for local development..."
echo "=========================================="

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo " Error: Python 3 is required but not installed"
    echo "   Download from: https://www.python.org/downloads/"
    exit 1
fi
echo "✅ Python 3 found"

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo " Error: Node.js is required but not installed"
    echo "   Download from: https://nodejs.org/"
    exit 1
fi
echo "✅ Node.js found"

# Backend setup
echo ""
echo "Step 1/4: Setting up Python backend..."
cd backend

if [ ! -d "venv" ]; then
    echo "  Creating virtual environment..."
    python3 -m venv venv
fi

echo "  Installing Python dependencies..."
source venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo "  Training ML model..."
python train.py

deactivate
cd ..

# Frontend setup
echo ""
echo "Step 2/4: Setting up React frontend..."
cd frontend

if [ ! -d "node_modules" ]; then
    echo "  Installing Node.js dependencies..."
    npm install --silent
fi

cd ..

# Create .env files
echo ""
echo "Step 3/4: Creating environment files..."
if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env
    echo "  Created backend/.env"
fi

if [ ! -f "frontend/.env" ]; then
    cp frontend/.env.example frontend/.env
    echo "  Created frontend/.env"
fi

# Final instructions
echo ""
echo "Step 4/4: Setup complete!"
echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "To start the application:"
echo ""
echo "  Terminal 1: make run-backend"
echo "  Terminal 2: make run-frontend"
echo ""
echo "Or use tmux/screen to run both:"
echo ""
echo "  # Install tmux (optional)"
echo "  brew install tmux  # macOS"
echo "  sudo apt install tmux  # Linux"
echo ""
echo "  # Start both services"
echo "  tmux new-session -d -s backend 'cd backend && source venv/bin/activate && python main.py'"
echo "  tmux new-session -d -s frontend 'cd frontend && npm run dev'"
echo ""
echo "  # View logs"
echo "  tmux attach -t backend"
echo "  tmux attach -t frontend"
echo ""
echo " Frontend: http://localhost:5173"
echo " Backend: http://localhost:8000"
echo " API Docs: http://localhost:8000/docs"
echo ""
echo "For OCI deployment:"
echo "  1. Run: oci setup config"
echo "  2. Generate SSH key: ssh-keygen -t rsa -b 4096 -f ~/.ssh/hackathon_key"
echo "  3. Configure: infra/terraform.tfvars"
echo "  4. Deploy: make init && make apply"
echo ""
