// ============================================================================
// API Configuration
// ============================================================================
// Configuration for the backend API
// ============================================================================

// Get API URL from environment variable or use default
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export const config = {
  apiUrl: API_URL,
  endpoints: {
    health: `${API_URL}/health`,
    healthDetailed: `${API_URL}/health/detailed`,
    predict: `${API_URL}/api/predict`,
    predictBatch: `${API_URL}/api/predict/batch`,
    modelInfo: `${API_URL}/api/model/info`,
    ingest: `${API_URL}/api/ingest`,
    ingestFile: `${API_URL}/api/ingest/file`,
    ingestStats: `${API_URL}/api/ingest/stats`,
  },
};

export default config;
