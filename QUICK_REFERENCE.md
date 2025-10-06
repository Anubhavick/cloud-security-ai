# ⚡ Quick Command Reference Card

**Print this and keep it handy!**

---

## 🚀 First Time Setup

```bash
# Automated (recommended)
./quick-setup.sh

# Manual
make setup-dev
```

---

## 🏃 Running the Application

### Local Development
```bash
# Terminal 1
make run-backend

# Terminal 2  
make run-frontend
```

### Docker (Easiest)
```bash
make docker-up
```

**Access:**
- Frontend: http://localhost or http://localhost:5173
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs

---

## 🤖 Training Models

### Basic Training
```bash
cd backend
source venv/bin/activate
python train.py
```

### Google Colab
1. Go to https://colab.research.google.com/
2. Copy code from `backend/train.py`
3. Train model
4. Download `model.joblib`
5. Replace in `backend/app/ml_models/model.joblib`

---

## 🛠️ Common Commands

```bash
# View all commands
make help

# Stop Docker
make docker-down

# View logs
make docker-logs

# Clean everything
make clean

# Test backend
curl http://localhost:8000/health

# Rebuild Docker
make docker-build
```

---

## 📁 Key Files

```
backend/
├── main.py              → FastAPI app
├── train.py             → Train models
└── app/
    ├── routers/
    │   ├── predict.py   → /api/predict
    │   └── ingest.py    → /api/ingest
    └── ml_models/
        └── model.joblib → Trained model

frontend/
└── src/
    ├── components/
    │   └── Dashboard.jsx → Main UI
    └── services/
        └── api.js        → API calls

infra/
├── main.tf              → Cloud resources
└── terraform.tfvars     → Your config
```

---

## 🐛 Quick Fixes

**Port already in use:**
```bash
# Find process
lsof -i :8000   # or :5173

# Kill it
kill -9 <PID>
```

**Model not found:**
```bash
cd backend
source venv/bin/activate
python train.py
```

**VS Code import errors:**
```
Cmd+Shift+P → "Python: Select Interpreter"
Choose: .venv/bin/python
```

**Docker won't start:**
```bash
make docker-clean
make docker-up
```

---

## 🌐 Testing APIs

### Health Check
```bash
curl http://localhost:8000/health
```

### Prediction
```bash
curl -X POST http://localhost:8000/api/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [5, 500, 3, 1]}'
```

---

## ☁️ Cloud Deployment

```bash
# Setup (one-time)
oci setup config
ssh-keygen -t rsa -b 4096 -f ~/.ssh/hackathon_key

# Configure infra/terraform.tfvars

# Deploy
make init
make plan
make apply

# Connect
make ssh-vm
```

---

## 🎯 Development Workflow

```bash
# 1. Pull latest
git pull origin main

# 2. Create branch
git checkout -b feature/my-feature

# 3. Make changes...

# 4. Test
make docker-up  # or local setup

# 5. Commit
git add .
git commit -m "Description"
git push origin feature/my-feature
```

---

## 📱 Quick URLs

- **Local Frontend:** http://localhost:5173
- **Docker Frontend:** http://localhost
- **Backend API:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs
- **Health Check:** http://localhost:8000/health

---

## 🆘 Help Resources

- **Full Guide:** `TEAM_GUIDE.md`
- **Docker Guide:** `DOCKER_SETUP.md`
- **Setup Guide:** `SETUP_GUIDE.md`
- **All Commands:** `make help`

---

**Save this file! Screenshot it! Print it! 📄**
