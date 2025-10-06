# 👥 Team Developer Guide - Cloud Security AI

This guide is for team members who want to contribute, customize, or train models.

## 🎯 Quick Reference

| Task | Command | Where to Run |
|------|---------|--------------|
| Run Backend | `make run-backend` | Terminal 1 |
| Run Frontend | `make run-frontend` | Terminal 2 |
| Train Model | `cd backend && source venv/bin/activate && python train.py` | Terminal |
| Run with Docker | `make docker-up` | Terminal |
| Deploy to Cloud | `make apply` | Terminal (after OCI setup) |
| View API Docs | Open `http://localhost:8000/docs` | Browser |

---

## 📚 Table of Contents

1. [First Time Setup](#first-time-setup)
2. [Running the Application](#running-the-application)
3. [Training the ML Model](#training-the-ml-model)
4. [Development Workflows](#development-workflows)
5. [VS Code Setup](#vs-code-setup)
6. [Google Colab Alternative](#google-colab-alternative)
7. [Infrastructure Explained](#infrastructure-explained)
8. [Troubleshooting](#troubleshooting)

---

## 🚀 First Time Setup

### Option 1: Automated Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/Anubhavick/cloud-security-ai.git
cd cloud-security-ai

# Run automated setup
chmod +x quick-setup.sh
./quick-setup.sh
# Choose option 2 for local development
```

### Option 2: Manual Setup

```bash
# 1. Setup Backend (Python)
cd backend
python3 -m venv venv           # Create virtual environment
source venv/bin/activate       # Activate it (on Windows: venv\Scripts\activate)
pip install -r requirements.txt # Install dependencies
python train.py                # Train the model
deactivate                     # Deactivate venv
cd ..

# 2. Setup Frontend (Node.js)
cd frontend
npm install                    # Install dependencies
cd ..

# 3. Create environment files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

---

## 🏃 Running the Application

### Method 1: Local Development (Fastest for Development)

**Terminal 1 - Backend:**
```bash
cd backend
source venv/bin/activate
python main.py
# Backend runs on http://localhost:8000
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
# Frontend runs on http://localhost:5173
```

**Using Makefile (Easier):**
```bash
# Terminal 1
make run-backend

# Terminal 2
make run-frontend
```

### Method 2: Docker (Easiest, Most Reliable)

```bash
# Start everything
make docker-up

# View logs
make docker-logs

# Stop everything
make docker-down
```

Access:
- Frontend: http://localhost
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Method 3: Background Mode (tmux/screen)

If you don't want to manage multiple terminals:

```bash
# Install tmux (one-time)
# macOS: brew install tmux
# Linux: sudo apt install tmux

# Start backend in background
tmux new-session -d -s backend 'cd backend && source venv/bin/activate && python main.py'

# Start frontend in background
tmux new-session -d -s frontend 'cd frontend && npm run dev'

# View backend logs
tmux attach -t backend
# Press Ctrl+B then D to detach

# View frontend logs
tmux attach -t frontend
# Press Ctrl+B then D to detach

# Stop services
tmux kill-session -t backend
tmux kill-session -t frontend
```

---

## 🤖 Training the ML Model

### Option 1: Train Locally (Recommended)

```bash
cd backend
source venv/bin/activate
python train.py
```

**Output:**
```
Training model...
Model accuracy: 0.955
Model saved to ./app/ml_models/model.joblib
```

### Option 2: Train with Custom Data

Edit `backend/train.py`:
```python
# Modify the create_synthetic_data() function
def create_synthetic_data(n_samples=1000):  # Change sample size
    # Add your own features
    # Load your own dataset
    # ...
```

Then run:
```bash
cd backend
source venv/bin/activate
python train.py
```

### Option 3: Train on Google Colab

**Step 1: Create a Colab Notebook**

Go to [Google Colab](https://colab.research.google.com/) and create a new notebook.

**Step 2: Install Dependencies**
```python
# Cell 1: Install dependencies
!pip install scikit-learn pandas numpy joblib
```

**Step 3: Copy Training Code**
```python
# Cell 2: Training code
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import joblib

def create_synthetic_data(n_samples=1000):
    """Create synthetic cybersecurity data"""
    np.random.seed(42)
    
    # Generate features
    failed_logins = np.random.randint(0, 20, n_samples)
    network_traffic = np.random.uniform(0, 1000, n_samples)
    suspicious_ports = np.random.randint(0, 10, n_samples)
    malware_signatures = np.random.randint(0, 5, n_samples)
    
    # Generate labels (threat or not)
    threat = (
        (failed_logins > 10) |
        (network_traffic > 800) |
        (suspicious_ports > 5) |
        (malware_signatures > 2)
    ).astype(int)
    
    # Create DataFrame
    df = pd.DataFrame({
        'failed_logins': failed_logins,
        'network_traffic': network_traffic,
        'suspicious_ports': suspicious_ports,
        'malware_signatures': malware_signatures,
        'threat': threat
    })
    
    return df

def train_model():
    """Train a Random Forest model"""
    print("Creating synthetic data...")
    df = create_synthetic_data(n_samples=1000)
    
    # Split features and target
    X = df.drop('threat', axis=1)
    y = df['threat']
    
    # Split into train and test sets
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train model
    print("Training model...")
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Model accuracy: {accuracy:.3f}")
    
    # Save model
    joblib.dump(model, 'model.joblib')
    print("Model saved to model.joblib")
    
    return model

# Train the model
model = train_model()
```

**Step 4: Download the Model**
```python
# Cell 3: Download model
from google.colab import files
files.download('model.joblib')
```

**Step 5: Use in Your Project**
1. Download `model.joblib` from Colab
2. Copy it to `backend/app/ml_models/model.joblib`
3. Restart your backend

### Option 4: Train with Jupyter Notebook

```bash
# Install Jupyter (one-time)
cd backend
source venv/bin/activate
pip install jupyter

# Start Jupyter
jupyter notebook

# Open train.py or create new notebook
# Run cells to train model
```

---

## 🛠️ Development Workflows

### Workflow 1: Frontend Development

```bash
# Terminal 1: Keep backend running
make run-backend

# Terminal 2: Frontend with hot reload
cd frontend
npm run dev

# Edit files in frontend/src/
# Changes auto-reload in browser
```

**Key Files:**
- `frontend/src/App.jsx` - Main app component
- `frontend/src/components/Dashboard.jsx` - Main dashboard
- `frontend/src/services/api.js` - API calls
- `frontend/src/config.js` - Configuration

### Workflow 2: Backend Development

```bash
# Terminal 1: Backend with auto-reload
cd backend
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Edit files in backend/
# Server auto-reloads on changes
```

**Key Files:**
- `backend/main.py` - FastAPI app entry point
- `backend/app/routers/predict.py` - Prediction endpoints
- `backend/app/routers/ingest.py` - Data ingestion
- `backend/app/ml_models/model_manager.py` - Model management

### Workflow 3: ML Model Development

```bash
# 1. Edit training code
code backend/train.py

# 2. Train new model
cd backend
source venv/bin/activate
python train.py

# 3. Test new model
python -c "
from app.ml_models.model_manager import ModelManager
mm = ModelManager()
result = mm.predict([5, 500, 3, 1])
print(f'Prediction: {result}')
"

# 4. Restart backend to use new model
# Ctrl+C in backend terminal, then:
python main.py
```

### Workflow 4: Full Stack Changes

```bash
# Use Docker for consistent environment
make docker-up

# Make changes to code

# Rebuild and restart
make docker-build
make docker-up

# Or for faster iteration:
make docker-down
make run-backend  # Terminal 1
make run-frontend # Terminal 2
```

---

## 💻 VS Code Setup

### Recommended Extensions

Install these VS Code extensions:

1. **Python** (ms-python.python)
2. **Pylance** (ms-python.vscode-pylance)
3. **ESLint** (dbaeumer.vscode-eslint)
4. **Prettier** (esbenp.prettier-vscode)
5. **Tailwind CSS IntelliSense** (bradlc.vscode-tailwindcss)
6. **Docker** (ms-azuretools.vscode-docker)
7. **Thunder Client** (rangav.vscode-thunder-client) - For testing APIs

### VS Code Configuration

The project already has `.vscode/settings.json` configured. It includes:
- Python environment settings
- Tailwind CSS support
- Auto-formatting settings

### Running in VS Code

**Method 1: Integrated Terminal**
```bash
# Split terminal (Ctrl+Shift+`)
# Terminal 1:
make run-backend

# Terminal 2:
make run-frontend
```

**Method 2: Debug Configuration**

Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: FastAPI",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": [
        "main:app",
        "--reload",
        "--host",
        "0.0.0.0",
        "--port",
        "8000"
      ],
      "jinja": true,
      "cwd": "${workspaceFolder}/backend"
    }
  ]
}
```

Then press F5 to start debugging.

### Testing API in VS Code

**Using Thunder Client:**
1. Install Thunder Client extension
2. Create new request
3. GET `http://localhost:8000/health`
4. POST `http://localhost:8000/api/predict`
   ```json
   {
     "features": [5, 500, 3, 1]
   }
   ```

---

## 🔬 Google Colab Alternative

### Why Use Colab?

- ✅ Free GPU/TPU for training
- ✅ No local setup needed
- ✅ Great for experimenting
- ✅ Easy to share with team

### Complete Colab Workflow

**1. Create Colab Notebook:**
- Go to https://colab.research.google.com/
- New Notebook → Rename to "Cloud Security AI Training"

**2. Mount Google Drive (Optional):**
```python
from google.colab import drive
drive.mount('/content/drive')
```

**3. Clone Repository:**
```python
!git clone https://github.com/Anubhavick/cloud-security-ai.git
%cd cloud-security-ai/backend
```

**4. Install Dependencies:**
```python
!pip install -r requirements.txt
```

**5. Train Model:**
```python
!python train.py
```

**6. Test Model:**
```python
from app.ml_models.model_manager import ModelManager

mm = ModelManager()
result = mm.predict([5, 500, 3, 1])
print(f"Prediction: {result}")
```

**7. Download Model:**
```python
from google.colab import files
files.download('app/ml_models/model.joblib')
```

**8. Upload to Your Project:**
- Download the file
- Replace `backend/app/ml_models/model.joblib`
- Restart backend

### Advanced Colab: Train with Your Data

```python
# Upload your dataset
from google.colab import files
uploaded = files.upload()

# Load and train
import pandas as pd
df = pd.read_csv('your_data.csv')

# Modify train.py to use df
# Train model
# Download result
```

---

## 🏗️ Infrastructure Explained

### Project Structure

```
cloud-security-ai/
│
├── infra/                    # Cloud infrastructure (Terraform)
│   ├── provider.tf          # OCI provider configuration
│   ├── variables.tf         # Input variables (region, tenancy, etc.)
│   ├── main.tf              # Resources (VCN, compute, storage)
│   ├── outputs.tf           # Output values (IPs, connection info)
│   ├── terraform.tfvars     # Your values (KEEP SECRET!)
│   └── cloud-init.yaml      # VM initialization script
│
├── backend/                  # Python FastAPI backend
│   ├── main.py              # FastAPI app entry point
│   ├── requirements.txt     # Python dependencies
│   ├── train.py             # ML model training script
│   ├── Dockerfile           # Docker image for backend
│   ├── .env                 # Environment variables (KEEP SECRET!)
│   └── app/
│       ├── routers/         # API endpoints
│       │   ├── health.py    # Health check: /health
│       │   ├── predict.py   # Predictions: /api/predict
│       │   └── ingest.py    # Data ingest: /api/ingest
│       └── ml_models/       # ML model management
│           ├── model_manager.py  # Load/predict with model
│           └── model.joblib      # Trained model file
│
├── frontend/                 # React frontend
│   ├── src/
│   │   ├── main.jsx         # React entry point
│   │   ├── App.jsx          # Main app component
│   │   ├── components/
│   │   │   └── Dashboard.jsx # Main dashboard UI
│   │   ├── services/
│   │   │   └── api.js       # API client
│   │   └── config.js        # Configuration
│   ├── package.json         # Node.js dependencies
│   ├── Dockerfile           # Docker image for frontend
│   └── nginx.conf           # Nginx configuration
│
├── docker-compose.yml        # Docker orchestration
├── Makefile                  # Convenient commands
└── README.md                 # Project documentation
```

### What Each Part Does

**`infra/` - Cloud Infrastructure**
- Creates resources in Oracle Cloud
- Defines network, compute, storage
- Uses Terraform (Infrastructure as Code)
- Run `make apply` to deploy to cloud

**`backend/` - API Server**
- FastAPI web server
- Loads ML model
- Provides REST API endpoints
- Runs on port 8000
- Python 3.13 + ML libraries

**`frontend/` - Web Interface**
- React web application
- Dashboard for predictions
- Calls backend API
- Runs on port 5173 (dev) or 80 (docker)
- Built with Vite + Tailwind CSS

**`docker-compose.yml` - Container Orchestration**
- Defines both backend and frontend containers
- Manages networking between them
- Handles health checks and restarts

### Command Cheat Sheet

```bash
# ===== LOCAL DEVELOPMENT =====

# First time setup
make setup-dev                # Setup everything

# Running
make run-backend              # Start backend (Terminal 1)
make run-frontend             # Start frontend (Terminal 2)

# Training
cd backend && source venv/bin/activate
python train.py               # Train ML model

# Testing
make test-backend             # Test backend API
curl http://localhost:8000/health

# ===== DOCKER =====

make docker-up                # Start with Docker
make docker-down              # Stop Docker
make docker-logs              # View logs
make docker-build             # Rebuild images
make docker-clean             # Remove everything

# ===== CLOUD DEPLOYMENT =====

# Prerequisites
oci setup config              # Configure OCI CLI (one-time)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/hackathon_key  # Generate SSH key

# Configure
# Edit infra/terraform.tfvars with your OCI details

# Deploy
make init                     # Initialize Terraform
make plan                     # Preview changes
make apply                    # Deploy to cloud
make output                   # Show connection details

# Connect
make ssh-vm                   # SSH to cloud instance
make deploy-backend           # Deploy backend to cloud

# Cleanup
make destroy                  # Destroy cloud resources

# ===== HELPFUL COMMANDS =====

make help                     # Show all commands
make clean                    # Clean build artifacts
```

---

## 🐛 Troubleshooting

### Backend Won't Start

```bash
# Check if port 8000 is in use
lsof -i :8000
# Kill process: kill -9 <PID>

# Check if virtual environment is activated
which python
# Should show: .../venv/bin/python

# Reinstall dependencies
cd backend
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Frontend Won't Start

```bash
# Check if port 5173 is in use
lsof -i :5173

# Clear cache and reinstall
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run dev
```

### Model Not Found Error

```bash
# Train the model
cd backend
source venv/bin/activate
python train.py

# Check if file exists
ls -lh app/ml_models/model.joblib
```

### Docker Issues

```bash
# Check if Docker is running
docker ps

# View detailed logs
docker-compose logs backend
docker-compose logs frontend

# Restart from scratch
make docker-clean
make docker-build
make docker-up
```

### Import Errors in VS Code

```bash
# Configure Python environment
# Cmd+Shift+P → "Python: Select Interpreter"
# Choose: .venv/bin/python

# Or reload window
# Cmd+Shift+P → "Developer: Reload Window"
```

---

## 🎓 Team Collaboration Tips

### For New Team Members

1. **Clone repository**
2. **Choose setup method** (Docker or Local)
3. **Run `quick-setup.sh`** for automated setup
4. **Test it works** (open http://localhost)
5. **Start coding!**

### Before Making Changes

```bash
# Pull latest changes
git pull origin main

# Create a branch
git checkout -b feature/your-feature-name

# Make changes...

# Test your changes
make docker-up  # Or make run-backend + make run-frontend

# Commit and push
git add .
git commit -m "Add your feature"
git push origin feature/your-feature-name
```

### Code Organization

- **Backend routes**: Add new endpoints in `backend/app/routers/`
- **ML models**: Update `backend/train.py` or `model_manager.py`
- **Frontend components**: Add UI in `frontend/src/components/`
- **API calls**: Update `frontend/src/services/api.js`

### Testing Changes

```bash
# Test backend
curl http://localhost:8000/health
curl -X POST http://localhost:8000/api/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [5, 500, 3, 1]}'

# Test frontend
# Open http://localhost:5173 (or http://localhost for Docker)
# Use browser DevTools to check console
```

---

## 📞 Getting Help

- **Documentation**: Check `README.md`, `DOCKER_SETUP.md`, `SETUP_GUIDE.md`
- **Commands**: Run `make help`
- **Logs**: Use `make docker-logs` or check terminal output
- **Team**: Ask in your team chat/Slack
- **Issues**: Check existing issues or create a new one

---

**Happy coding! 🚀**
