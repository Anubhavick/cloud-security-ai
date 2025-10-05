// ============================================================================
// Dashboard Component
// ============================================================================
// Main dashboard for Cloud Security AI application
// ============================================================================

import { useState, useEffect } from 'react';
import * as api from '../services/api';

const Dashboard = () => {
  // State management
  const [apiStatus, setApiStatus] = useState(null);
  const [modelInfo, setModelInfo] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // Prediction form state
  const [features, setFeatures] = useState(['1.5', '2.3', '4.1', '0.8']);
  const [predictionResult, setPredictionResult] = useState(null);
  const [predicting, setPredicting] = useState(false);

  // Check API health on component mount
  useEffect(() => {
    checkApiHealth();
    fetchModelInfo();
  }, []);

  /**
   * Check API health status
   */
  const checkApiHealth = async () => {
    try {
      const health = await api.healthCheck();
      setApiStatus(health);
      setError(null);
    } catch (err) {
      setError('Unable to connect to backend API. Make sure the server is running.');
      console.error('Health check failed:', err);
    }
  };

  /**
   * Fetch model information
   */
  const fetchModelInfo = async () => {
    try {
      const info = await api.getModelInfo();
      setModelInfo(info);
    } catch (err) {
      console.error('Failed to fetch model info:', err);
    }
  };

  /**
   * Handle prediction request
   */
  const handlePredict = async (e) => {
    e.preventDefault();
    setPredicting(true);
    setPredictionResult(null);
    
    try {
      // Convert features to numbers
      const featureValues = features.map(f => parseFloat(f));
      
      // Validate features
      if (featureValues.some(isNaN)) {
        throw new Error('All features must be valid numbers');
      }
      
      // Make prediction
      const result = await api.predict(featureValues);
      setPredictionResult(result);
      setError(null);
    } catch (err) {
      setError(err.response?.data?.detail || err.message || 'Prediction failed');
      console.error('Prediction error:', err);
    } finally {
      setPredicting(false);
    }
  };

  /**
   * Handle feature input change
   */
  const handleFeatureChange = (index, value) => {
    const newFeatures = [...features];
    newFeatures[index] = value;
    setFeatures(newFeatures);
  };

  /**
   * Add a new feature input
   */
  const addFeature = () => {
    setFeatures([...features, '0.0']);
  };

  /**
   * Remove a feature input
   */
  const removeFeature = (index) => {
    if (features.length > 1) {
      const newFeatures = features.filter((_, i) => i !== index);
      setFeatures(newFeatures);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                Cloud Security AI
              </h1>
              <p className="mt-1 text-sm text-gray-500">
                Oracle Hackathon 2025 - AI/ML + Cybersecurity + OCI
              </p>
            </div>
            <div className="flex items-center space-x-4">
              {/* API Status Indicator */}
              <div className="flex items-center space-x-2">
                <div className={`h-3 w-3 rounded-full ${apiStatus ? 'bg-green-500 animate-pulse' : 'bg-red-500'}`}></div>
                <span className="text-sm text-gray-600">
                  {apiStatus ? 'API Connected' : 'API Offline'}
                </span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Error Alert */}
        {error && (
          <div className="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
            <div className="flex">
              <div className="flex-shrink-0">
                <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                </svg>
              </div>
              <div className="ml-3">
                <h3 className="text-sm font-medium text-red-800">Error</h3>
                <div className="mt-2 text-sm text-red-700">
                  <p>{error}</p>
                </div>
              </div>
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Model Info Card */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-semibold text-gray-900 mb-4">
                Model Information
              </h2>
              {modelInfo ? (
                <div className="space-y-3">
                  <div>
                    <p className="text-sm font-medium text-gray-500">Version</p>
                    <p className="text-lg text-gray-900">{modelInfo.model_version}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-500">Type</p>
                    <p className="text-lg text-gray-900">{modelInfo.model_type}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-500">Features</p>
                    <p className="text-lg text-gray-900">{modelInfo.features_count}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-500">Status</p>
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      {modelInfo.status}
                    </span>
                  </div>
                </div>
              ) : (
                <div className="text-gray-500">Loading model info...</div>
              )}
            </div>
          </div>

          {/* Prediction Form */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-semibold text-gray-900 mb-4">
                Make a Prediction
              </h2>
              
              <form onSubmit={handlePredict} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Feature Values
                  </label>
                  <div className="space-y-2">
                    {features.map((feature, index) => (
                      <div key={index} className="flex items-center space-x-2">
                        <span className="text-sm text-gray-500 w-20">Feature {index + 1}</span>
                        <input
                          type="text"
                          value={feature}
                          onChange={(e) => handleFeatureChange(index, e.target.value)}
                          className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                          placeholder="0.0"
                        />
                        {features.length > 1 && (
                          <button
                            type="button"
                            onClick={() => removeFeature(index)}
                            className="p-2 text-red-600 hover:bg-red-50 rounded-md"
                          >
                            <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          </button>
                        )}
                      </div>
                    ))}
                  </div>
                  <button
                    type="button"
                    onClick={addFeature}
                    className="mt-2 text-sm text-blue-600 hover:text-blue-700"
                  >
                    + Add Feature
                  </button>
                </div>

                <div className="flex space-x-3">
                  <button
                    type="submit"
                    disabled={predicting}
                    className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {predicting ? 'Predicting...' : 'Predict'}
                  </button>
                  <button
                    type="button"
                    onClick={checkApiHealth}
                    className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
                  >
                    Test Connection
                  </button>
                </div>
              </form>

              {/* Prediction Result */}
              {predictionResult && (
                <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                  <h3 className="text-lg font-semibold text-gray-900 mb-3">
                    Prediction Result
                  </h3>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm font-medium text-gray-500">Prediction</p>
                      <p className="text-2xl font-bold text-blue-600">
                        {predictionResult.prediction}
                      </p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">Confidence</p>
                      <p className="text-2xl font-bold text-blue-600">
                        {(predictionResult.confidence * 100).toFixed(2)}%
                      </p>
                    </div>
                  </div>
                  <div className="mt-3">
                    <p className="text-sm text-gray-600">
                      Model Version: {predictionResult.model_version}
                    </p>
                    <p className="text-sm text-gray-600">
                      {predictionResult.message}
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Info Section */}
        <div className="mt-8 bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">
            About This Project
          </h2>
          <div className="prose prose-blue max-w-none">
            <p className="text-gray-600">
              This is a hackathon project combining <strong>AI/ML</strong>, <strong>Cybersecurity</strong>, 
              and <strong>Oracle Cloud Infrastructure (OCI)</strong>. The application demonstrates:
            </p>
            <ul className="list-disc list-inside text-gray-600 space-y-1 mt-3">
              <li>FastAPI backend with ML model inference</li>
              <li>React frontend with Tailwind CSS</li>
              <li>OCI infrastructure provisioned with Terraform</li>
              <li>Containerized deployment with Docker</li>
              <li>Real-time predictions and data ingestion</li>
            </ul>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 mt-8">
        <div className="border-t border-gray-200 pt-6">
          <p className="text-center text-gray-500 text-sm">
            Oracle Hackathon 2025 - Cloud Security AI Project
          </p>
        </div>
      </footer>
    </div>
  );
};

export default Dashboard;
