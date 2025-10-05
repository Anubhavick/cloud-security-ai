# ============================================================================
# Train ML Model Script
# ============================================================================
# This script trains an ML model and saves it for use by the API
# Run this script to train/retrain your model with new data
# ============================================================================

import os
import sys
import logging
import argparse
import pandas as pd
import numpy as np
from pathlib import Path
import joblib

# ML libraries
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.preprocessing import StandardScaler

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def create_synthetic_data(n_samples: int = 1000, n_features: int = 4) -> pd.DataFrame:
    """
    Create synthetic data for training (for demonstration)
    Replace this with your actual data loading logic
    
    Args:
        n_samples: Number of samples to generate
        n_features: Number of features
    
    Returns:
        DataFrame with features and labels
    """
    from sklearn.datasets import make_classification
    
    logger.info(f"Creating synthetic data: {n_samples} samples, {n_features} features")
    
    X, y = make_classification(
        n_samples=n_samples,
        n_features=n_features,
        n_informative=int(n_features * 0.75),
        n_redundant=int(n_features * 0.25),
        n_classes=2,
        random_state=42
    )
    
    # Create DataFrame
    feature_names = [f'feature_{i}' for i in range(n_features)]
    df = pd.DataFrame(X, columns=feature_names)
    df['label'] = y
    
    return df

def load_data(data_path: str = None) -> pd.DataFrame:
    """
    Load training data from file or create synthetic data
    
    Args:
        data_path: Path to data file (CSV)
    
    Returns:
        DataFrame with features and labels
    """
    if data_path and os.path.exists(data_path):
        logger.info(f"Loading data from {data_path}")
        df = pd.read_csv(data_path)
        return df
    else:
        logger.warning("No data file provided or file not found")
        logger.info("Creating synthetic data for demonstration")
        return create_synthetic_data()

def train_model(df: pd.DataFrame, model_output_path: str = "./app/ml_models/model.joblib"):
    """
    Train an ML model and save it
    
    Args:
        df: DataFrame with features and labels
        model_output_path: Path to save the trained model
    """
    logger.info("Starting model training...")
    
    # Separate features and labels
    # Assuming the last column is the label
    X = df.iloc[:, :-1].values
    y = df.iloc[:, -1].values
    
    logger.info(f"Features shape: {X.shape}")
    logger.info(f"Labels shape: {y.shape}")
    
    # Split into train and test sets
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    logger.info(f"Training set: {X_train.shape[0]} samples")
    logger.info(f"Test set: {X_test.shape[0]} samples")
    
    # Create and train the model
    # You can replace this with any other model (XGBoost, Neural Network, etc.)
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    
    logger.info("Training Random Forest model...")
    model.fit(X_train, y_train)
    
    # Evaluate the model
    train_score = model.score(X_train, y_train)
    test_score = model.score(X_test, y_test)
    
    logger.info(f"Training accuracy: {train_score:.4f}")
    logger.info(f"Test accuracy: {test_score:.4f}")
    
    # Make predictions
    y_pred = model.predict(X_test)
    
    # Print classification report
    logger.info("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    
    # Print confusion matrix
    logger.info("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # Save the model
    logger.info(f"Saving model to {model_output_path}")
    Path(model_output_path).parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(model, model_output_path)
    
    logger.info("Model training completed successfully!")
    
    return model

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Train ML model for Cloud Security AI')
    parser.add_argument(
        '--data',
        type=str,
        default=None,
        help='Path to training data CSV file'
    )
    parser.add_argument(
        '--output',
        type=str,
        default='./app/ml_models/model.joblib',
        help='Path to save the trained model'
    )
    
    args = parser.parse_args()
    
    # Load data
    df = load_data(args.data)
    
    # Train model
    train_model(df, args.output)

if __name__ == "__main__":
    main()
