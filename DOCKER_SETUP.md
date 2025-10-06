# 🚀 Docker Setup Guide - Cloud Security AI

## Quick Start with Docker (Recommended for Easy Setup)

The easiest way to run this project is using Docker. This method works on **any system** (Windows, macOS, Linux) without needing to install Python, Node.js, or any dependencies manually.

### Prerequisites

1. **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop/)
2. **Docker Compose** (included with Docker Desktop)

### 🎯 One-Command Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd cloud-security-ai

# Train the ML model (one-time setup)
cd backend
python3 train.py  # or python train.py on Windows
cd ..

# Start everything with Docker
make docker-up
```

That's it! The application will be available at:
- **Frontend**: http://localhost
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

### 📋 Docker Commands

```bash
# Start all services
make docker-up

# View logs (real-time)
make docker-logs

# Stop all services
make docker-down

# Restart services
make docker-restart

# Rebuild images (after code changes)
make docker-build

# Clean everything (remove containers, volumes, images)
make docker-clean
```

### 🔧 Manual Docker Commands (without Makefile)

If you don't have `make` installed:

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

### 📦 What's Included?

The Docker setup includes:

1. **Backend Container**
   - FastAPI application
   - Python 3.13
   - All ML/AI dependencies
   - Auto-restart on failure
   - Health checks

2. **Frontend Container**
   - React application
   - Vite build
   - Nginx web server
   - Optimized production build
   - Health checks

3. **Networking**
   - Internal Docker network for service communication
   - Exposed ports: 80 (frontend), 8000 (backend)

### 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│           Docker Compose                    │
│                                             │
│  ┌──────────────┐      ┌─────────────────┐ │
│  │  Frontend    │      │    Backend      │ │
│  │  (Nginx)     │─────▶│    (FastAPI)    │ │
│  │  Port: 80    │      │    Port: 8000   │ │
│  └──────────────┘      └─────────────────┘ │
│         │                       │           │
│         │                       │           │
│         ▼                       ▼           │
│  ┌──────────────────────────────────────┐  │
│  │      Cloud Security Network         │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### 🔍 Troubleshooting

#### Port Already in Use

If port 80 or 8000 is already in use:

```bash
# Edit docker-compose.yml and change ports:
# For frontend: "8080:80" instead of "80:80"
# For backend: "8001:8000" instead of "8000:8000"
```

#### Container Won't Start

```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Restart specific service
docker-compose restart backend
```

#### Need to Rebuild After Code Changes

```bash
# Rebuild and restart
docker-compose up -d --build
```

#### Model Not Found Error

```bash
# Train the model first
cd backend
python3 train.py
cd ..

# Then restart Docker
make docker-down
make docker-up
```

### 🌐 Environment Variables

You can customize settings by editing `docker-compose.yml`:

**Backend:**
- `PORT`: Backend port (default: 8000)
- `HOST`: Backend host (default: 0.0.0.0)
- `ALLOWED_ORIGINS`: CORS origins
- `ENVIRONMENT`: production/development

**Frontend:**
- `VITE_API_URL`: Backend API URL

### 📊 Health Checks

Both services have built-in health checks:

```bash
# Check backend health
curl http://localhost:8000/health

# Check frontend health
curl http://localhost/health

# View health status in Docker
docker-compose ps
```

### 🚀 Production Deployment

For production deployment to cloud:

1. **Build optimized images:**
   ```bash
   docker-compose build --no-cache
   ```

2. **Push to container registry:**
   ```bash
   docker tag cloud-security-backend:latest your-registry/backend:latest
   docker tag cloud-security-frontend:latest your-registry/frontend:latest
   docker push your-registry/backend:latest
   docker push your-registry/frontend:latest
   ```

3. **Deploy to OCI/AWS/Azure:**
   - Use the provided Terraform scripts in `infra/`
   - Or use Kubernetes manifests
   - Or use cloud-specific container services

### 🎓 For Hackathon Participants

**Quick demo setup:**

```bash
# 1. Clone repo
git clone <repo-url>
cd cloud-security-ai

# 2. Train model (30 seconds)
cd backend && python3 train.py && cd ..

# 3. Start with Docker (2 minutes)
make docker-up

# 4. Open browser
open http://localhost
```

**That's it! Ready to present in 3 minutes! 🎉**

### 📝 Next Steps

1. ✅ Basic setup working
2. 🔧 Customize ML model in `backend/train.py`
3. 🎨 Customize UI in `frontend/src/components/Dashboard.jsx`
4. 🚀 Deploy to cloud with `make apply` (optional)
5. 📊 Add more features and endpoints

### 💡 Tips

- **Development**: Use local setup (`make setup-dev`) for faster iteration
- **Demo/Production**: Use Docker for reliability and portability
- **Team collaboration**: Share Docker images instead of "works on my machine"
- **CI/CD**: Docker setup is ready for automated deployments

### 🆘 Need Help?

Check these resources:
- `README.md` - Full project documentation
- `SETUP_GUIDE.md` - Detailed local setup
- `docker-compose.yml` - Container configuration
- `backend/Dockerfile` & `frontend/Dockerfile` - Image definitions

---

**Ready to build something amazing! 🚀**
