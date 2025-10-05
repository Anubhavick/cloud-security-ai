# ============================================================================
# Model Manager
# ============================================================================
# Manages loading, saving, and using ML models
# ============================================================================

import os
import joblib
import logging
import numpy as np
from typing import Tuple, Any, Optional
from pathlib import Path

logger = logging.getLogger(__name__)

class ModelManager:
    """
    Manages ML models for the application
    Handles loading, saving, and making predictions
    """
    
    def __init__(self, model_path: str = "./app/ml_models/model.joblib"):
        """
        Initialize the model manager
        
        Args:
            model_path: Path to the model file
        """
        self.model_path = model_path
        self.model = None
        self.model_version = "1.0.0"
        self.model_type = "DummyClassifier"
        
        # Try to load the model
        self.load_model()
    
    def load_model(self) -> bool:
        """
        Load the ML model from disk
        
        Returns:
            True if model loaded successfully, False otherwise
        """
        try:
            if os.path.exists(self.model_path):
                self.model = joblib.load(self.model_path)
                logger.info(f"Model loaded successfully from {self.model_path}")
                return True
            else:
                logger.warning(f"Model file not found at {self.model_path}")
                logger.info("Creating a dummy model for demonstration")
                self._create_dummy_model()
                return True
        except Exception as e:
            logger.error(f"Error loading model: {e}")
            logger.info("Creating a dummy model for demonstration")
            self._create_dummy_model()
            return False
    
    def _create_dummy_model(self):
        """
        Create a simple dummy model for demonstration purposes
        This can be replaced with a real trained model
        """
        from sklearn.ensemble import RandomForestClassifier
        from sklearn.datasets import make_classification
        
        # Create synthetic data for training
        X, y = make_classification(
            n_samples=100,
            n_features=4,
            n_informative=3,
            n_redundant=1,
            random_state=42
        )
        
        # Train a simple Random Forest model
        self.model = RandomForestClassifier(n_estimators=10, random_state=42)
        self.model.fit(X, y)
        
        # Save the model
        self.save_model()
        
        logger.info("Dummy model created and saved")
    
    def save_model(self, model_path: Optional[str] = None) -> bool:
        """
        Save the current model to disk
        
        Args:
            model_path: Optional custom path to save the model
        
        Returns:
            True if model saved successfully, False otherwise
        """
        try:
            path = model_path or self.model_path
            
            # Create directory if it doesn't exist
            Path(path).parent.mkdir(parents=True, exist_ok=True)
            
            # Save the model
            joblib.dump(self.model, path)
            logger.info(f"Model saved successfully to {path}")
            return True
        except Exception as e:
            logger.error(f"Error saving model: {e}")
            return False
    
    def predict(self, features: np.ndarray) -> Tuple[Any, float]:
        """
        Make a prediction using the loaded model
        
        Args:
            features: Input features as numpy array
        
        Returns:
            Tuple of (prediction, confidence_score)
        """
        if self.model is None:
            raise ValueError("No model loaded")
        
        try:
            # Make prediction
            prediction = self.model.predict(features)[0]
            
            # Get confidence score (probability)
            if hasattr(self.model, 'predict_proba'):
                probabilities = self.model.predict_proba(features)[0]
                confidence = float(max(probabilities))
            else:
                # If model doesn't support probabilities, return 1.0
                confidence = 1.0
            
            # Convert numpy types to Python native types for JSON serialization
            if hasattr(prediction, 'item'):
                prediction = prediction.item()
            
            return prediction, confidence
            
        except Exception as e:
            logger.error(f"Error during prediction: {e}")
            raise
    
    def get_model_version(self) -> str:
        """Get the current model version"""
        return self.model_version
    
    def get_model_type(self) -> str:
        """Get the model type"""
        return self.model_type
    
    def get_features_count(self) -> int:
        """Get the number of features the model expects"""
        if self.model is None:
            return 0
        
        try:
            if hasattr(self.model, 'n_features_in_'):
                return self.model.n_features_in_
            return 4  # Default for dummy model
        except:
            return 0
