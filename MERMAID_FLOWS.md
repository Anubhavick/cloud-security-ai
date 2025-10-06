# 🎨 Visual Flow Diagrams (Mermaid)

These diagrams use Mermaid syntax and will render beautifully on GitHub, VS Code (with Mermaid extension), and many markdown viewers.

---

## 📊 System Architecture

```mermaid
graph TB
    subgraph Browser["🌐 Web Browser"]
        UI[User Interface<br/>localhost:5173]
    end
    
    subgraph Frontend["⚛️ Frontend Container"]
        React[React App<br/>Dashboard UI]
        API_Client[API Client<br/>axios]
    end
    
    subgraph Backend["🐍 Backend Container"]
        FastAPI[FastAPI Server<br/>Port 8000]
        Routes[API Routes<br/>/health, /predict, /ingest]
        ModelMgr[Model Manager<br/>Load & Predict]
        ML[ML Model<br/>model.joblib]
    end
    
    UI --> React
    React --> API_Client
    API_Client -->|HTTP POST| FastAPI
    FastAPI --> Routes
    Routes --> ModelMgr
    ModelMgr --> ML
    ML -->|Prediction| ModelMgr
    ModelMgr -->|Response| Routes
    Routes -->|JSON| FastAPI
    FastAPI -->|Result| API_Client
    API_Client --> React
    React --> UI
    
    style UI fill:#e1f5ff
    style React fill:#61dafb
    style FastAPI fill:#009688
    style ML fill:#ff6b6b
```

---

## 🔄 Prediction Request Flow

```mermaid
sequenceDiagram
    participant User
    participant Dashboard as Dashboard.jsx
    participant API as api.js
    participant FastAPI as main.py
    participant Router as predict.py
    participant Manager as model_manager.py
    participant Model as model.joblib
    
    User->>Dashboard: Clicks "Predict"<br/>Input: [5, 500, 3, 1]
    Dashboard->>API: axios.post('/api/predict')
    API->>FastAPI: HTTP POST Request
    FastAPI->>Router: Route to /api/predict
    Router->>Router: Validate input
    Router->>Manager: predict(features)
    Manager->>Model: Run inference
    Model->>Manager: Return: 1 or 0
    Manager->>Router: prediction + confidence
    Router->>FastAPI: JSON response
    FastAPI->>API: HTTP Response
    API->>Dashboard: Update state
    Dashboard->>User: Display result ✅
```

---

## 🐳 Docker Compose Architecture

```mermaid
graph LR
    subgraph DockerCompose["🐳 Docker Compose"]
        subgraph Frontend["Frontend Container"]
            FrontBuild[Build Stage<br/>node:24-alpine<br/>npm build]
            FrontServe[Serve Stage<br/>nginx:alpine<br/>Port 80]
            FrontBuild --> FrontServe
        end
        
        subgraph Backend["Backend Container"]
            BackBuild[Build Stage<br/>python:3.13-slim<br/>pip install]
            BackRun[Runtime Stage<br/>uvicorn<br/>Port 8000]
            BackBuild --> BackRun
        end
        
        Network[Internal Network<br/>cloud-security-network]
        
        FrontServe <--> Network
        BackRun <--> Network
    end
    
    Host[Host Machine<br/>localhost:80<br/>localhost:8000]
    
    Host <--> FrontServe
    Host <--> BackRun
    
    style FrontBuild fill:#61dafb
    style FrontServe fill:#269bd2
    style BackBuild fill:#306998
    style BackRun fill:#009688
    style Network fill:#ffd700
```

---

## 🚀 Development Workflow

```mermaid
flowchart TD
    Start([👨‍💻 Start Development]) --> Choice{Choose Setup Method}
    
    Choice -->|Easy & Reliable| Docker[🐳 Docker Setup]
    Choice -->|Fast Iteration| Local[💻 Local Setup]
    
    Docker --> DockerUp[make docker-up]
    Local --> LocalSetup[make setup-dev]
    
    DockerUp --> Running
    LocalSetup --> LocalRun[Terminal 1: make run-backend<br/>Terminal 2: make run-frontend]
    LocalRun --> Running
    
    Running[✅ Application Running<br/>Frontend & Backend Live]
    
    Running --> Code[📝 Make Changes<br/>Edit code, Add features]
    Code --> Test[🧪 Test Changes<br/>Browser, API Docs, curl]
    
    Test --> Works{Works?}
    Works -->|✅ Yes| Commit[📦 Commit & Push<br/>git add, commit, push]
    Works -->|❌ No| Debug[🐛 Debug<br/>Check logs, Fix issues]
    
    Debug --> Code
    
    Commit --> Deploy{Deploy?}
    Deploy -->|Local Demo| End1([✨ Demo Ready])
    Deploy -->|Production| Cloud[☁️ Deploy to Cloud<br/>make apply]
    Cloud --> End2([🚀 Live in Production])
    
    style Start fill:#4CAF50
    style Running fill:#2196F3
    style Commit fill:#9C27B0
    style End1 fill:#FF9800
    style End2 fill:#F44336
```

---

## 🤖 ML Model Training Flow

```mermaid
flowchart TD
    Start([🎓 Start Training]) --> Method{Choose Training Method}
    
    Method -->|Have Python| Local[💻 Local Training]
    Method -->|Need GPU| Colab[☁️ Google Colab]
    Method -->|Want Jupyter| Jupyter[📓 Jupyter Notebook]
    
    Local --> TrainScript
    Colab --> TrainScript
    Jupyter --> TrainScript
    
    TrainScript[📄 train.py] --> LoadData[1️⃣ Load/Create Data<br/>Synthetic or Real Dataset]
    LoadData --> Preprocess[2️⃣ Preprocess Data<br/>Clean, Feature Engineering]
    Preprocess --> Train[3️⃣ Train Model<br/>RandomForest Algorithm]
    Train --> Evaluate[4️⃣ Evaluate Model<br/>Accuracy, Metrics]
    Evaluate --> GoodModel{Good Accuracy?}
    
    GoodModel -->|❌ No| Tune[Tune Parameters<br/>Adjust hyperparameters]
    Tune --> Train
    
    GoodModel -->|✅ Yes| Save[5️⃣ Save Model<br/>→ model.joblib]
    Save --> Deploy[6️⃣ Deploy Model<br/>Copy to app/ml_models/]
    Deploy --> Restart[Restart Backend]
    Restart --> TestPred[🧪 Test Predictions]
    TestPred --> Success([✅ Model Live!])
    
    style Start fill:#4CAF50
    style Train fill:#2196F3
    style Save fill:#9C27B0
    style Success fill:#FF9800
```

---

## ☁️ Cloud Deployment Flow

```mermaid
flowchart TD
    Start([🚀 Ready to Deploy]) --> CheckLocal{Local Setup<br/>Working?}
    
    CheckLocal -->|❌ No| FixLocal[Fix Local Issues First]
    FixLocal --> CheckLocal
    
    CheckLocal -->|✅ Yes| ConfigOCI[1️⃣ Configure OCI<br/>oci setup config]
    ConfigOCI --> GenSSH[2️⃣ Generate SSH Key<br/>ssh-keygen]
    GenSSH --> EditVars[3️⃣ Edit terraform.tfvars<br/>Add tenancy, region, etc.]
    
    EditVars --> TFInit[4️⃣ Initialize Terraform<br/>make init]
    TFInit --> TFPlan[5️⃣ Preview Changes<br/>make plan]
    
    TFPlan --> Review{Review OK?}
    Review -->|❌ Adjust| EditVars
    
    Review -->|✅ Yes| TFApply[6️⃣ Deploy Infrastructure<br/>make apply]
    
    TFApply --> Creating[Creating Resources...]
    Creating --> Resources
    
    subgraph Resources[☁️ OCI Resources Created]
        Comp[Compartment]
        VCN[VCN + Subnet]
        IGW[Internet Gateway]
        SecList[Security Lists]
        Compute[Compute Instance]
        Storage[Object Storage]
    end
    
    Resources --> DeployApp[7️⃣ Deploy Application<br/>make deploy-backend]
    DeployApp --> CopyFiles[Copy files to instance]
    CopyFiles --> BuildDocker[Build Docker image]
    BuildDocker --> RunContainer[Run container]
    
    RunContainer --> GetIP[8️⃣ Get Public IP<br/>make output]
    GetIP --> TestCloud[🧪 Test in Browser<br/>http://public-ip]
    
    TestCloud --> Success([✅ Live in Cloud!<br/>🌍 Public URL Ready])
    
    style Start fill:#4CAF50
    style TFApply fill:#FF9800
    style Success fill:#F44336
```

---

## 🔄 Git Workflow for Teams

```mermaid
gitGraph
    commit id: "Initial project"
    commit id: "Add backend"
    commit id: "Add frontend"
    
    branch feature/ml-model
    checkout feature/ml-model
    commit id: "Train model"
    commit id: "Improve accuracy"
    
    checkout main
    branch feature/ui-dashboard
    checkout feature/ui-dashboard
    commit id: "Create dashboard"
    commit id: "Add charts"
    
    checkout main
    merge feature/ml-model tag: "v1.0-model"
    
    checkout feature/ui-dashboard
    commit id: "Polish UI"
    
    checkout main
    merge feature/ui-dashboard tag: "v1.0-ui"
    
    commit id: "Deploy to production" type: HIGHLIGHT
```

---

## 🧪 Testing Flow

```mermaid
flowchart LR
    subgraph Testing["🧪 Testing Strategy"]
        direction TB
        
        Unit[Unit Tests<br/>pytest backend/]
        Integration[Integration Tests<br/>Test API endpoints]
        E2E[E2E Tests<br/>Test full flow]
        Manual[Manual Testing<br/>Browser testing]
        
        Unit --> Integration
        Integration --> E2E
        E2E --> Manual
    end
    
    Code[📝 Write Code] --> Testing
    Testing --> Pass{All Pass?}
    
    Pass -->|❌ No| Fix[🐛 Fix Issues]
    Fix --> Code
    
    Pass -->|✅ Yes| Deploy[🚀 Deploy]
    
    style Unit fill:#4CAF50
    style Integration fill:#2196F3
    style E2E fill:#9C27B0
    style Deploy fill:#FF9800
```

---

## 📦 File Dependency Graph

```mermaid
graph TD
    subgraph Root["Project Root"]
        Compose[docker-compose.yml]
        Makefile[Makefile]
    end
    
    subgraph BackendFiles["Backend Files"]
        MainPy[main.py]
        TrainPy[train.py]
        Reqs[requirements.txt]
        
        subgraph Routers["app/routers/"]
            Health[health.py]
            Predict[predict.py]
            Ingest[ingest.py]
        end
        
        subgraph Models["app/ml_models/"]
            ModelMgr[model_manager.py]
            ModelFile[model.joblib]
        end
    end
    
    subgraph FrontendFiles["Frontend Files"]
        Package[package.json]
        MainJsx[main.jsx]
        AppJsx[App.jsx]
        
        subgraph Components["components/"]
            Dashboard[Dashboard.jsx]
        end
        
        subgraph Services["services/"]
            ApiJs[api.js]
        end
    end
    
    Compose --> MainPy
    Compose --> Package
    Makefile --> Compose
    
    MainPy --> Health
    MainPy --> Predict
    MainPy --> Ingest
    
    Predict --> ModelMgr
    ModelMgr --> ModelFile
    TrainPy -.creates.-> ModelFile
    
    MainJsx --> AppJsx
    AppJsx --> Dashboard
    Dashboard --> ApiJs
    ApiJs -.calls.-> MainPy
    
    style Compose fill:#4CAF50
    style MainPy fill:#2196F3
    style ModelFile fill:#FF9800
    style Dashboard fill:#61dafb
```

---

## 🎯 Decision Tree: Choose Setup Method

```mermaid
flowchart TD
    Start{Need to demo<br/>RIGHT NOW?} -->|Yes ⚡| Docker1[Use Docker<br/>make docker-up]
    Start -->|No| Q2{Have Python<br/>& Node.js?}
    
    Q2 -->|No| Docker2[Use Docker<br/>Easiest setup]
    Q2 -->|Yes| Q3{Need fast<br/>code changes?}
    
    Q3 -->|Yes| Local[Use Local Setup<br/>make setup-dev]
    Q3 -->|No| Q4{Share with<br/>team?}
    
    Q4 -->|Yes| Docker3[Use Docker<br/>Consistency]
    Q4 -->|No| Q5{Need public<br/>URL?}
    
    Q5 -->|Yes| Cloud[Deploy to Cloud<br/>make apply]
    Q5 -->|No| Either[Either Docker<br/>or Local]
    
    Docker1 --> Success1([✅ Demo Ready])
    Docker2 --> Success2([✅ Easy Setup])
    Docker3 --> Success3([✅ Team Ready])
    Local --> Success4([✅ Dev Ready])
    Cloud --> Success5([✅ Production])
    Either --> Success6([✅ Flexible])
    
    style Start fill:#4CAF50
    style Docker1 fill:#2196F3
    style Local fill:#9C27B0
    style Cloud fill:#FF9800
```

---

## 🔄 CI/CD Pipeline (Future)

```mermaid
flowchart LR
    subgraph Dev["👨‍💻 Development"]
        Code[Write Code]
        Commit[git commit]
        Push[git push]
    end
    
    subgraph CI["🔄 CI Pipeline"]
        Test[Run Tests]
        Build[Build Docker]
        Scan[Security Scan]
    end
    
    subgraph CD["🚀 CD Pipeline"]
        Deploy[Deploy to Dev]
        Approve{Manual<br/>Approval?}
        Prod[Deploy to Prod]
    end
    
    Code --> Commit
    Commit --> Push
    Push --> Test
    Test --> Build
    Build --> Scan
    
    Scan --> Pass{Pass?}
    Pass -->|❌ No| Notify[Notify Team]
    Notify --> Code
    
    Pass -->|✅ Yes| Deploy
    Deploy --> Approve
    Approve -->|✅ Approved| Prod
    Approve -->|❌ Rejected| Code
    
    Prod --> Monitor[📊 Monitor]
    
    style Code fill:#4CAF50
    style Test fill:#2196F3
    style Deploy fill:#9C27B0
    style Prod fill:#FF9800
    style Monitor fill:#F44336
```

---

## 🎓 Learning Path

```mermaid
flowchart TD
    Start([👋 New to Project]) --> Read[📖 Read README.md]
    Read --> Choose{What's your<br/>goal?}
    
    Choose -->|Quick Demo| Path1[🎯 Demo Path]
    Choose -->|Join Team| Path2[👥 Team Path]
    Choose -->|Deep Learning| Path3[🎓 Learning Path]
    
    Path1 --> Docker[Run Docker<br/>make docker-up]
    Docker --> Demo([✨ Demo Ready!])
    
    Path2 --> TeamGuide[Read TEAM_GUIDE.md]
    TeamGuide --> Setup[Setup Environment]
    Setup --> Contribute([💻 Start Contributing!])
    
    Path3 --> Arch[Read ARCHITECTURE.md]
    Arch --> Code[Read Source Code]
    Code --> Experiment[Experiment & Learn]
    Experiment --> Expert([🧠 Expert Level!])
    
    style Start fill:#4CAF50
    style Demo fill:#2196F3
    style Contribute fill:#9C27B0
    style Expert fill:#FF9800
```

---

## 📊 Data Flow in the System

```mermaid
flowchart LR
    subgraph Input["📥 Input"]
        User[User Input<br/>Security Features]
    end
    
    subgraph Processing["⚙️ Processing"]
        Validate[Validate Data]
        Transform[Transform Format]
        Predict[ML Prediction]
    end
    
    subgraph Output["📤 Output"]
        Result[Prediction Result]
        Viz[Visualization]
        Alert[Alert/Action]
    end
    
    subgraph Storage["💾 Storage"]
        Model[(ML Model)]
        Logs[(Logs)]
        Data[(Training Data)]
    end
    
    User --> Validate
    Validate --> Transform
    Transform --> Predict
    
    Model --> Predict
    Predict --> Result
    Result --> Viz
    Result --> Alert
    
    Predict --> Logs
    User --> Data
    
    style User fill:#4CAF50
    style Predict fill:#2196F3
    style Result fill:#9C27B0
    style Model fill:#FF9800
```

---

## 🔐 Security Flow (Future Enhancement)

```mermaid
flowchart TD
    Request[Incoming Request] --> Auth{Authenticated?}
    
    Auth -->|❌ No| Reject1[401 Unauthorized]
    Auth -->|✅ Yes| RateLimit{Rate Limit<br/>OK?}
    
    RateLimit -->|❌ No| Reject2[429 Too Many Requests]
    RateLimit -->|✅ Yes| Validate{Input<br/>Valid?}
    
    Validate -->|❌ No| Reject3[400 Bad Request]
    Validate -->|✅ Yes| Process[Process Request]
    
    Process --> Log[Log Activity]
    Log --> Response[Return Response]
    
    Response --> Monitor[Monitor for Anomalies]
    
    style Auth fill:#4CAF50
    style Process fill:#2196F3
    style Monitor fill:#FF9800
    style Reject1 fill:#F44336
    style Reject2 fill:#F44336
    style Reject3 fill:#F44336
```

---

## 🎨 How to View These Diagrams

### On GitHub
✅ Automatically rendered - Just push to GitHub!

### In VS Code
1. Install extension: **Markdown Preview Mermaid Support**
2. Open this file
3. Press `Cmd+Shift+V` (Preview)

### Online Editors
- [Mermaid Live Editor](https://mermaid.live/)
- Copy any diagram and paste to edit/view

### Export Options
- PNG image
- SVG vector
- PDF document

---

**These diagrams make the architecture crystal clear! 🎯**
