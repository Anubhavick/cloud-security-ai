# 🏗️ Architecture & Flow Diagrams

Visual guide to understand how everything works together.

> 💡 **Prefer interactive diagrams?** Check out **[MERMAID_FLOWS.md](./MERMAID_FLOWS.md)** for beautiful, GitHub-rendered flowcharts!

---

## 📊 System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         YOUR COMPUTER                             │
│                                                                   │
│  ┌────────────────────┐              ┌─────────────────────┐    │
│  │    Web Browser     │              │    VS Code          │    │
│  │  localhost:5173    │              │   (Development)     │    │
│  └────────┬───────────┘              └─────────────────────┘    │
│           │                                                       │
│           │ HTTP Requests                                        │
│           ▼                                                       │
│  ┌────────────────────────────────────────────────────┐         │
│  │              Frontend (React)                       │         │
│  │  • Dashboard UI                                     │         │
│  │  • Input forms                                      │         │
│  │  • API client                                       │         │
│  │  Port: 5173 (dev) or 80 (docker)                  │         │
│  └────────────────────┬───────────────────────────────┘         │
│                       │                                          │
│                       │ REST API Calls                           │
│                       │ (axios)                                  │
│                       ▼                                          │
│  ┌────────────────────────────────────────────────────┐         │
│  │              Backend (FastAPI)                      │         │
│  │  ┌──────────────────────────────────────────────┐  │         │
│  │  │  API Endpoints                                │  │         │
│  │  │  • /health                                    │  │         │
│  │  │  • /api/predict                              │  │         │
│  │  │  • /api/ingest                               │  │         │
│  │  │  • /docs (Swagger)                           │  │         │
│  │  └──────────────┬───────────────────────────────┘  │         │
│  │                 │                                    │         │
│  │                 ▼                                    │         │
│  │  ┌──────────────────────────────────────────────┐  │         │
│  │  │  Model Manager                                │  │         │
│  │  │  • Load model.joblib                         │  │         │
│  │  │  • Run predictions                           │  │         │
│  │  │  • Return results                            │  │         │
│  │  └──────────────┬───────────────────────────────┘  │         │
│  │                 │                                    │         │
│  │                 ▼                                    │         │
│  │  ┌──────────────────────────────────────────────┐  │         │
│  │  │  ML Model (RandomForest)                     │  │         │
│  │  │  • model.joblib                              │  │         │
│  │  │  • Trained on cybersecurity data             │  │         │
│  │  └──────────────────────────────────────────────┘  │         │
│  │  Port: 8000                                         │         │
│  └─────────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Request Flow

### Prediction Request Flow

```
User enters data in browser
         │
         ▼
┌─────────────────────┐
│  Dashboard.jsx      │  1. User clicks "Predict"
│  (Frontend)         │     Input: [5, 500, 3, 1]
└──────────┬──────────┘
           │
           │ 2. axios.post('/api/predict', {features: [...]})
           ▼
┌─────────────────────┐
│  api.js             │  3. Format request
│  (API Client)       │     Add headers
└──────────┬──────────┘
           │
           │ 4. HTTP POST request
           ▼
┌─────────────────────┐
│  main.py            │  5. Receive request
│  (FastAPI)          │     Route to handler
└──────────┬──────────┘
           │
           │ 6. Route to /api/predict
           ▼
┌─────────────────────┐
│  predict.py         │  7. Validate input
│  (Router)           │     Extract features
└──────────┬──────────┘
           │
           │ 8. Call model_manager.predict()
           ▼
┌─────────────────────┐
│  model_manager.py   │  9. Load model
│  (Model Manager)    │     Run prediction
└──────────┬──────────┘
           │
           │ 10. Use trained model
           ▼
┌─────────────────────┐
│  model.joblib       │  11. ML inference
│  (ML Model)         │      Return: 1 or 0
└──────────┬──────────┘
           │
           │ 12. Return prediction + confidence
           ▼
┌─────────────────────┐
│  predict.py         │  13. Format response
│  (Router)           │      Add metadata
└──────────┬──────────┘
           │
           │ 14. JSON response
           ▼
┌─────────────────────┐
│  api.js             │  15. Parse response
│  (API Client)       │      Handle errors
└──────────┬──────────┘
           │
           │ 16. Update state
           ▼
┌─────────────────────┐
│  Dashboard.jsx      │  17. Display result
│  (Frontend)         │      Show to user
└─────────────────────┘
```

---

## 🐳 Docker Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    docker-compose.yml                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │         Frontend Container                           │  │
│  │                                                      │  │
│  │  Stage 1: Build                                     │  │
│  │  ┌────────────────────────────┐                     │  │
│  │  │  node:24-alpine            │                     │  │
│  │  │  npm install               │                     │  │
│  │  │  npm run build             │                     │  │
│  │  │  → dist/ folder            │                     │  │
│  │  └────────────────────────────┘                     │  │
│  │                                                      │  │
│  │  Stage 2: Serve                                     │  │
│  │  ┌────────────────────────────┐                     │  │
│  │  │  nginx:alpine              │                     │  │
│  │  │  Copy dist/ to /usr/share/nginx/html            │  │
│  │  │  nginx.conf                │                     │  │
│  │  └────────────────────────────┘                     │  │
│  │                                                      │  │
│  │  Port: 80 → Host                                    │  │
│  │  Health: /health                                    │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │                                       │
│                     │ Internal Network                      │
│                     │ (cloud-security-network)              │
│                     ▼                                       │
│  ┌─────────────────────────────────────────────────────┐  │
│  │         Backend Container                            │  │
│  │                                                      │  │
│  │  Stage 1: Build                                     │  │
│  │  ┌────────────────────────────┐                     │  │
│  │  │  python:3.13-slim          │                     │  │
│  │  │  pip install dependencies  │                     │  │
│  │  └────────────────────────────┘                     │  │
│  │                                                      │  │
│  │  Stage 2: Runtime                                   │  │
│  │  ┌────────────────────────────┐                     │  │
│  │  │  python:3.13-slim          │                     │  │
│  │  │  Copy app code             │                     │  │
│  │  │  Copy dependencies         │                     │  │
│  │  │  uvicorn main:app          │                     │  │
│  │  └────────────────────────────┘                     │  │
│  │                                                      │  │
│  │  Port: 8000 → Host                                  │  │
│  │  Health: /health                                    │  │
│  │  Volumes: data/, ml_models/                         │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## 🔄 Development Workflow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                  Start Development                       │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────┐
         │  Choose Setup Method    │
         └─────────┬───────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
┌──────────────┐      ┌──────────────┐
│    Docker    │      │    Local     │
│  make docker-up     │  make setup-dev
└──────┬───────┘      └──────┬───────┘
       │                     │
       └──────────┬──────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  Application Running                │
│  Frontend: http://localhost         │
│  Backend: http://localhost:8000     │
└──────────────────┬──────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Make Changes       │
         │  • Edit code        │
         │  • Add features     │
         │  • Fix bugs         │
         └─────────┬───────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Test Changes       │
         │  • Browser          │
         │  • API Docs         │
         │  • curl commands    │
         └─────────┬───────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
┌──────────────┐      ┌──────────────┐
│   Works?     │      │   Errors?    │
│   ✓ Good!    │      │   ✗ Debug    │
└──────┬───────┘      └──────┬───────┘
       │                     │
       │                     └─────┐
       ▼                           │
┌──────────────┐                   │
│  Commit      │                   │
│  git add .   │                   │
│  git commit  │                   │
│  git push    │                   │
└──────────────┘                   │
       │                           │
       ▼                           │
┌──────────────┐                   │
│  Deploy      │                   │
│  • Docker    │                   │
│  • Cloud     │                   │
└──────────────┘                   │
                                   │
                 ┌─────────────────┘
                 │
                 ▼
         ┌──────────────┐
         │  View Logs   │
         │  Fix Issue   │
         └──────┬───────┘
                │
                └────────────┐
                             │
                             ▼
                   Back to Make Changes
```

---

## 🤖 ML Model Training Flow

```
┌────────────────────────────────────────────┐
│          Training Method                    │
└──────────┬─────────────────────────────────┘
           │
    ┌──────┴────────┬──────────────┐
    │               │              │
    ▼               ▼              ▼
┌────────┐    ┌──────────┐   ┌──────────┐
│ Local  │    │  Colab   │   │ Jupyter  │
└───┬────┘    └────┬─────┘   └────┬─────┘
    │              │              │
    │              │              │
    └──────┬───────┴───────┬──────┘
           │               │
           ▼               │
    ┌──────────────┐       │
    │  train.py    │◄──────┘
    └──────┬───────┘
           │
           ▼
    ┌──────────────────────────────┐
    │  1. Load/Create Data         │
    │     • Synthetic data         │
    │     • Real dataset           │
    │     • From CSV/DB            │
    └──────────────┬───────────────┘
                   │
                   ▼
    ┌──────────────────────────────┐
    │  2. Preprocess Data          │
    │     • Clean data             │
    │     • Feature engineering    │
    │     • Train/test split       │
    └──────────────┬───────────────┘
                   │
                   ▼
    ┌──────────────────────────────┐
    │  3. Train Model              │
    │     • RandomForest           │
    │     • Other algorithms       │
    │     • Hyperparameter tuning  │
    └──────────────┬───────────────┘
                   │
                   ▼
    ┌──────────────────────────────┐
    │  4. Evaluate Model           │
    │     • Accuracy               │
    │     • Precision/Recall       │
    │     • Confusion matrix       │
    └──────────────┬───────────────┘
                   │
                   ▼
    ┌──────────────────────────────┐
    │  5. Save Model               │
    │     → model.joblib           │
    └──────────────┬───────────────┘
                   │
                   ▼
    ┌──────────────────────────────┐
    │  6. Deploy Model             │
    │     • Copy to app/ml_models/ │
    │     • Restart backend        │
    │     • Test predictions       │
    └──────────────────────────────┘
```

---

## ☁️ Cloud Deployment Flow

```
┌─────────────────────────────────────────┐
│       Local Development                  │
│  • Code working                          │
│  • Docker tested                         │
│  • Ready to deploy                       │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  1. Configure OCI                       │
│     • oci setup config                  │
│     • Enter tenancy details             │
│     • Generate SSH key                  │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  2. Configure Terraform                 │
│     • Edit infra/terraform.tfvars       │
│     • Add tenancy_ocid                  │
│     • Add region                        │
│     • Add compartment_ocid              │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  3. Initialize Terraform                │
│     make init                           │
│     • Download providers                │
│     • Setup backend                     │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  4. Preview Changes                     │
│     make plan                           │
│     • Review resources                  │
│     • Check costs                       │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  5. Deploy Infrastructure               │
│     make apply                          │
│     Creates:                            │
│     • Compartment                       │
│     • VCN + Subnet                      │
│     • Internet Gateway                  │
│     • Security Lists                    │
│     • Compute Instance                  │
│     • Object Storage                    │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  6. Deploy Application                  │
│     make deploy-backend                 │
│     • Copy files to instance            │
│     • Build Docker image                │
│     • Run container                     │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  7. Access Application                  │
│     • Get public IP                     │
│     • Open in browser                   │
│     • Test endpoints                    │
└─────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  Application Running in Cloud!          │
│  http://<public-ip>                     │
└─────────────────────────────────────────┘
```

---

## 📦 File Dependency Graph

```
docker-compose.yml
    │
    ├── backend/Dockerfile
    │   └── backend/requirements.txt
    │       └── Python packages
    │
    └── frontend/Dockerfile
        └── frontend/package.json
            └── Node packages

main.py (Backend entry)
    │
    ├── app/routers/health.py
    ├── app/routers/predict.py
    │   └── app/ml_models/model_manager.py
    │       └── app/ml_models/model.joblib
    │           └── train.py (creates this)
    └── app/routers/ingest.py

main.jsx (Frontend entry)
    │
    └── App.jsx
        └── components/Dashboard.jsx
            └── services/api.js
                └── config.js

infra/main.tf
    │
    ├── infra/provider.tf
    ├── infra/variables.tf
    ├── infra/terraform.tfvars
    ├── infra/outputs.tf
    └── infra/cloud-init.yaml
```

---

## 🎯 Quick Decision Trees

### Which Setup Method?

```
Need to demo NOW?
├─ Yes → Docker (make docker-up)
└─ No  → Continue

Need to make code changes?
├─ Yes → Local (make setup-dev)
└─ No  → Docker

Need to share with team?
├─ Yes → Docker
└─ No  → Either

Need public URL?
└─ Yes → Cloud (make apply)
```

### Where to Train Model?

```
Have Python locally?
├─ Yes → Local (python train.py)
└─ No  → Continue

Need GPU?
├─ Yes → Google Colab
└─ No  → Continue

Want Jupyter?
├─ Yes → jupyter notebook
└─ No  → Local or Colab
```

### Where to Edit Code?

```
Comfortable with VS Code?
├─ Yes → VS Code
└─ No  → Any editor

Need debugging?
├─ Yes → VS Code with debugger
└─ No  → Any editor

Want IntelliSense?
├─ Yes → VS Code
└─ No  → Any editor
```

---

**Use these diagrams to understand the system! 🎯**
