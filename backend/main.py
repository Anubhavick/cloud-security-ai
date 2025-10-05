# ============================================================================
# FastAPI Backend - Main Application
# ============================================================================
# This is the main FastAPI application with ML/AI endpoints
# for the Oracle Hackathon Cloud Security AI project
# ============================================================================

from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging
import os
from typing import Dict, Any, Optional
import json

# Import routers
from app.routers import health, predict, ingest
from app.ml_models.model_manager import ModelManager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ============================================================================
# FastAPI Application Initialization
# ============================================================================

app = FastAPI(
    title="Cloud Security AI API",
    description="AI/ML API for Oracle Hackathon - Cybersecurity + Cloud",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# ============================================================================
# CORS Middleware Configuration
# ============================================================================
# Allow frontend to make requests to this backend
# In production, restrict allowed_origins to your frontend domain

allowed_origins = os.getenv("ALLOWED_ORIGINS", "*").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,  # In production, use specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# Application Startup/Shutdown Events
# ============================================================================

@app.on_event("startup")
async def startup_event():
    """Initialize resources on application startup"""
    logger.info("Starting Cloud Security AI API...")
    logger.info("Loading ML models...")
    
    # Initialize model manager
    try:
        model_manager = ModelManager()
        app.state.model_manager = model_manager
        logger.info("ML models loaded successfully")
    except Exception as e:
        logger.error(f"Error loading ML models: {e}")
        logger.warning("API will start, but predictions may fail")

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup resources on application shutdown"""
    logger.info("Shutting down Cloud Security AI API...")

# ============================================================================
# Include Routers
# ============================================================================

app.include_router(health.router, tags=["Health"])
app.include_router(predict.router, prefix="/api", tags=["Predictions"])
app.include_router(ingest.router, prefix="/api", tags=["Data Ingestion"])

# ============================================================================
# Root Endpoint
# ============================================================================

@app.get("/")
async def root():
    """Root endpoint - API information"""
    return {
        "message": "Cloud Security AI API",
        "version": "1.0.0",
        "hackathon": "Oracle Hackathon 2025",
        "docs": "/docs",
        "health": "/health"
    }

# ============================================================================
# Run Application (for local development)
# ============================================================================

if __name__ == "__main__":
    import uvicorn
    
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("HOST", "0.0.0.0")
    
    logger.info(f"Starting server on {host}:{port}")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=True,  # Enable auto-reload during development
        log_level="info"
    )
