# Backend - Cloud Security AI API

FastAPI-based backend for the Oracle Hackathon Cloud Security AI project.

## Features

- **FastAPI** - Modern, fast web framework for building APIs
- **ML/AI Integration** - Endpoints for model predictions and data ingestion
- **Health Monitoring** - Health check endpoints with system metrics
- **Docker Support** - Containerized deployment
- **Logging** - Comprehensive logging for debugging and monitoring

## API Endpoints

### Health
- `GET /health` - Basic health check
- `GET /health/detailed` - Detailed health with system metrics

### Predictions
- `POST /api/predict` - Make a single prediction
- `POST /api/predict/batch` - Make batch predictions
- `GET /api/model/info` - Get model information

### Data Ingestion
- `POST /api/ingest` - Ingest JSON data
- `POST /api/ingest/file` - Upload CSV file
- `GET /api/ingest/stats` - Get ingestion statistics

## Local Development

### Prerequisites
- Python 3.13+
- pip

### Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On macOS/Linux
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Train the model (optional):
```bash
python train.py
```

5. Run the server:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

6. Access the API:
- API: http://localhost:8000
- Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Docker Deployment

### Build the image:
```bash
docker build -t cloud-security-ai-backend .
```

### Run the container:
```bash
docker run -d -p 8000:8000 --name backend cloud-security-ai-backend
```

## Deployment to OCI Compute Instance

After provisioning infrastructure with Terraform:

1. SSH into the instance:
```bash
ssh -i ~/.ssh/hackathon_key opc@<instance_public_ip>
```

2. Clone the repository:
```bash
git clone <your-repo-url>
cd cloud-security-ai/backend
```

3. Run with Docker:
```bash
docker build -t backend .
docker run -d -p 8000:8000 --restart unless-stopped backend
```

Or run directly with uvicorn:
```bash
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

## Project Structure

```
backend/
├── main.py              # FastAPI application entry point
├── requirements.txt     # Python dependencies
├── Dockerfile          # Docker configuration
├── .env.example        # Environment variables template
├── train.py            # Model training script
├── app/
│   ├── __init__.py
│   ├── routers/        # API route handlers
│   │   ├── health.py   # Health check endpoints
│   │   ├── predict.py  # Prediction endpoints
│   │   └── ingest.py   # Data ingestion endpoints
│   └── ml_models/      # ML models
│       ├── model_manager.py  # Model management
│       └── model.joblib      # Trained model (generated)
└── data/               # Training data storage
```

## Training a Custom Model

Replace the dummy model with your own:

1. Prepare your data in CSV format
2. Run the training script:
```bash
python train.py --data your_data.csv --output ./app/ml_models/model.joblib
```

3. Restart the API server

## Testing

Test the API with curl:

```bash
# Health check
curl http://localhost:8000/health

# Make a prediction
curl -X POST http://localhost:8000/api/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [1.5, 2.3, 4.1, 0.8]}'

# Ingest data
curl -X POST http://localhost:8000/api/ingest \
  -H "Content-Type: application/json" \
  -d '{"data": [{"feature1": 1.5, "feature2": 2.3, "label": 0}]}'
```
