# ============================================================================
# Ingest Router
# ============================================================================
# Handles data ingestion for training and retraining models
# ============================================================================

from fastapi import APIRouter, HTTPException, UploadFile, File, Request
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
import logging
import json
import pandas as pd
from io import StringIO

logger = logging.getLogger(__name__)
router = APIRouter()

# ============================================================================
# Request/Response Models
# ============================================================================

class DataIngestRequest(BaseModel):
    """Request model for data ingestion"""
    data: List[Dict[str, Any]] = Field(
        ..., 
        description="List of data records to ingest",
        example=[
            {"feature1": 1.5, "feature2": 2.3, "label": 0},
            {"feature1": 3.1, "feature2": 4.2, "label": 1}
        ]
    )
    dataset_name: Optional[str] = Field(
        default="default",
        description="Name of the dataset"
    )

class DataIngestResponse(BaseModel):
    """Response model for data ingestion"""
    status: str = Field(..., description="Status of the ingestion")
    records_ingested: int = Field(..., description="Number of records ingested")
    dataset_name: str = Field(..., description="Name of the dataset")
    message: str = Field(..., description="Status message")

# ============================================================================
# Ingestion Endpoints
# ============================================================================

@router.post("/ingest", response_model=DataIngestResponse)
async def ingest_data(ingest_request: DataIngestRequest):
    """
    Ingest data for training or analysis
    
    Args:
        ingest_request: Data records to ingest
    
    Returns:
        Ingestion status and statistics
    """
    try:
        logger.info(f"Received data ingestion request: {len(ingest_request.data)} records")
        
        # Convert to DataFrame for processing
        df = pd.DataFrame(ingest_request.data)
        
        # Validate data
        if df.empty:
            raise HTTPException(status_code=400, detail="No data provided")
        
        # Save data to a file (in production, save to Object Storage)
        dataset_path = f"./data/{ingest_request.dataset_name}.csv"
        df.to_csv(dataset_path, index=False, mode='a', header=not pd.io.common.file_exists(dataset_path))
        
        logger.info(f"Data ingested successfully: {len(df)} records saved to {dataset_path}")
        
        return DataIngestResponse(
            status="success",
            records_ingested=len(df),
            dataset_name=ingest_request.dataset_name,
            message=f"Successfully ingested {len(df)} records"
        )
        
    except Exception as e:
        logger.error(f"Error during data ingestion: {e}")
        raise HTTPException(status_code=500, detail=f"Ingestion error: {str(e)}")

@router.post("/ingest/file", response_model=DataIngestResponse)
async def ingest_file(
    file: UploadFile = File(...),
    dataset_name: Optional[str] = "uploaded"
):
    """
    Ingest data from a CSV file upload
    
    Args:
        file: CSV file to upload
        dataset_name: Name for the dataset
    
    Returns:
        Ingestion status and statistics
    """
    try:
        logger.info(f"Received file upload: {file.filename}")
        
        # Read the file
        contents = await file.read()
        
        # Parse CSV
        try:
            df = pd.read_csv(StringIO(contents.decode('utf-8')))
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Error parsing CSV: {str(e)}")
        
        # Validate data
        if df.empty:
            raise HTTPException(status_code=400, detail="No data in file")
        
        # Save data
        dataset_path = f"./data/{dataset_name}.csv"
        df.to_csv(dataset_path, index=False, mode='a', header=not pd.io.common.file_exists(dataset_path))
        
        logger.info(f"File ingested successfully: {len(df)} records from {file.filename}")
        
        return DataIngestResponse(
            status="success",
            records_ingested=len(df),
            dataset_name=dataset_name,
            message=f"Successfully ingested {len(df)} records from {file.filename}"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error during file ingestion: {e}")
        raise HTTPException(status_code=500, detail=f"File ingestion error: {str(e)}")

@router.get("/ingest/stats")
async def ingestion_stats():
    """
    Get statistics about ingested data
    
    Returns:
        Statistics about available datasets
    """
    try:
        import os
        
        data_dir = "./data"
        if not os.path.exists(data_dir):
            return {
                "total_datasets": 0,
                "datasets": [],
                "message": "No data ingested yet"
            }
        
        datasets = []
        for filename in os.listdir(data_dir):
            if filename.endswith('.csv'):
                filepath = os.path.join(data_dir, filename)
                df = pd.read_csv(filepath)
                datasets.append({
                    "name": filename.replace('.csv', ''),
                    "records": len(df),
                    "features": len(df.columns)
                })
        
        return {
            "total_datasets": len(datasets),
            "datasets": datasets,
            "message": f"Found {len(datasets)} datasets"
        }
        
    except Exception as e:
        logger.error(f"Error getting ingestion stats: {e}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
