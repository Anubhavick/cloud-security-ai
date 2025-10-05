# ============================================================================
# Health Check Router
# ============================================================================
# Provides endpoints to check the health and status of the API
# ============================================================================

from fastapi import APIRouter, Request
import time
import psutil
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

# Store the start time of the application
start_time = time.time()

@router.get("/health")
async def health_check():
    """
    Basic health check endpoint
    Returns the status of the API
    """
    return {
        "status": "healthy",
        "service": "Cloud Security AI API",
        "timestamp": time.time()
    }

@router.get("/health/detailed")
async def detailed_health_check(request: Request):
    """
    Detailed health check with system metrics
    Returns API status, uptime, and system resources
    """
    uptime = time.time() - start_time
    
    # Get system metrics
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    # Check if models are loaded
    model_status = "unknown"
    try:
        if hasattr(request.app.state, 'model_manager'):
            model_status = "loaded"
        else:
            model_status = "not_loaded"
    except Exception as e:
        logger.error(f"Error checking model status: {e}")
        model_status = "error"
    
    return {
        "status": "healthy",
        "service": "Cloud Security AI API",
        "uptime_seconds": uptime,
        "model_status": model_status,
        "system": {
            "cpu_percent": cpu_percent,
            "memory": {
                "total_gb": round(memory.total / (1024**3), 2),
                "available_gb": round(memory.available / (1024**3), 2),
                "percent_used": memory.percent
            },
            "disk": {
                "total_gb": round(disk.total / (1024**3), 2),
                "free_gb": round(disk.free / (1024**3), 2),
                "percent_used": disk.percent
            }
        },
        "timestamp": time.time()
    }
