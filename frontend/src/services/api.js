// ============================================================================
// API Service
// ============================================================================
// Service layer for making API calls to the backend
// ============================================================================

import axios from 'axios';
import config from '../config';

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: config.apiUrl,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    // Add any auth tokens here if needed
    // const token = localStorage.getItem('token');
    // if (token) {
    //   config.headers.Authorization = `Bearer ${token}`;
    // }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    // Handle errors globally
    if (error.response) {
      console.error('API Error:', error.response.data);
    } else if (error.request) {
      console.error('Network Error:', error.message);
    } else {
      console.error('Error:', error.message);
    }
    return Promise.reject(error);
  }
);

// ============================================================================
// API Methods
// ============================================================================

/**
 * Health check
 */
export const healthCheck = async () => {
  const response = await apiClient.get('/health');
  return response.data;
};

/**
 * Detailed health check
 */
export const detailedHealthCheck = async () => {
  const response = await apiClient.get('/health/detailed');
  return response.data;
};

/**
 * Make a prediction
 * @param {Array<number>} features - Feature values
 * @param {string} modelVersion - Model version (optional)
 */
export const predict = async (features, modelVersion = 'latest') => {
  const response = await apiClient.post('/api/predict', {
    features,
    model_version: modelVersion,
  });
  return response.data;
};

/**
 * Make batch predictions
 * @param {Array<Object>} requests - Array of prediction requests
 */
export const predictBatch = async (requests) => {
  const response = await apiClient.post('/api/predict/batch', requests);
  return response.data;
};

/**
 * Get model information
 */
export const getModelInfo = async () => {
  const response = await apiClient.get('/api/model/info');
  return response.data;
};

/**
 * Ingest data
 * @param {Array<Object>} data - Data records to ingest
 * @param {string} datasetName - Dataset name
 */
export const ingestData = async (data, datasetName = 'default') => {
  const response = await apiClient.post('/api/ingest', {
    data,
    dataset_name: datasetName,
  });
  return response.data;
};

/**
 * Upload and ingest file
 * @param {File} file - File to upload
 * @param {string} datasetName - Dataset name
 */
export const ingestFile = async (file, datasetName = 'uploaded') => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('dataset_name', datasetName);
  
  const response = await apiClient.post('/api/ingest/file', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
  return response.data;
};

/**
 * Get ingestion statistics
 */
export const getIngestStats = async () => {
  const response = await apiClient.get('/api/ingest/stats');
  return response.data;
};

export default {
  healthCheck,
  detailedHealthCheck,
  predict,
  predictBatch,
  getModelInfo,
  ingestData,
  ingestFile,
  getIngestStats,
};
