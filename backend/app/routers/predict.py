# ============================================================================
# Predict Router
# ============================================================================
# Handles ML prediction requests
# ============================================================================

from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
import logging
import numpy as np

logger = logging.getLogger(__name__)
router = APIRouter()

# ============================================================================
# Request/Response Models
# ============================================================================

class PredictionRequest(BaseModel):
    """Request model for predictions"""
    features: List[float] = Field(
        ..., 
        description="List of feature values for prediction",
        example=[1.5, 2.3, 4.1, 0.8]
    )
    model_version: Optional[str] = Field(
        default="latest",
        description="Version of the model to use"
    )

class PredictionResponse(BaseModel):
    """Response model for predictions"""
    prediction: Any = Field(..., description="Model prediction result")
    confidence: Optional[float] = Field(None, description="Prediction confidence score")
    model_version: str = Field(..., description="Model version used")
    message: str = Field(..., description="Status message")

# ============================================================================
# Prediction Endpoints
# ============================================================================

@router.post("/predict", response_model=PredictionResponse)
async def predict(request: Request, prediction_request: PredictionRequest):
    """
    Make a prediction using the loaded ML model
    
    Args:
        prediction_request: Features to predict on
    
    Returns:
        Prediction result with confidence score
    """
    try:
        logger.info(f"Received prediction request with {len(prediction_request.features)} features")
        
        # Get the model manager from app state
        if not hasattr(request.app.state, 'model_manager'):
            raise HTTPException(
                status_code=503,
                detail="Model not loaded. Please check server logs."
            )
        
        model_manager = request.app.state.model_manager
        
        # Make prediction
        features = np.array(prediction_request.features).reshape(1, -1)
        prediction, confidence = model_manager.predict(features)
        
        logger.info(f"Prediction: {prediction}, Confidence: {confidence}")
        
        return PredictionResponse(
            prediction=prediction,
            confidence=confidence,
            model_version=model_manager.get_model_version(),
            message="Prediction successful"
        )
        
    except ValueError as e:
        logger.error(f"Invalid input: {e}")
        raise HTTPException(status_code=400, detail=f"Invalid input: {str(e)}")
    except Exception as e:
        logger.error(f"Error during prediction: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@router.post("/predict/batch", response_model=List[PredictionResponse])
async def predict_batch(request: Request, prediction_requests: List[PredictionRequest]):
    """
    Make batch predictions
    
    Args:
        prediction_requests: List of prediction requests
    
    Returns:
        List of prediction results
    """
    try:
        logger.info(f"Received batch prediction request with {len(prediction_requests)} items")
        
        # Get the model manager from app state
        if not hasattr(request.app.state, 'model_manager'):
            raise HTTPException(
                status_code=503,
                detail="Model not loaded. Please check server logs."
            )
        
        model_manager = request.app.state.model_manager
        
        results = []
        for req in prediction_requests:
            features = np.array(req.features).reshape(1, -1)
            prediction, confidence = model_manager.predict(features)
            
            results.append(PredictionResponse(
                prediction=prediction,
                confidence=confidence,
                model_version=model_manager.get_model_version(),
                message="Prediction successful"
            ))
        
        logger.info(f"Batch prediction completed: {len(results)} predictions")
        return results
        
    except Exception as e:
        logger.error(f"Error during batch prediction: {e}")
        raise HTTPException(status_code=500, detail=f"Batch prediction error: {str(e)}")

@router.get("/model/info")
async def model_info(request: Request):
    """
    Get information about the loaded model
    
    Returns:
        Model metadata and information
    """
    try:
        if not hasattr(request.app.state, 'model_manager'):
            raise HTTPException(
                status_code=503,
                detail="Model not loaded. Please check server logs."
            )
        
        model_manager = request.app.state.model_manager
        
        return {
            "model_version": model_manager.get_model_version(),
            "model_type": model_manager.get_model_type(),
            "features_count": model_manager.get_features_count(),
            "status": "loaded"
        }
        
    except Exception as e:
        logger.error(f"Error getting model info: {e}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
