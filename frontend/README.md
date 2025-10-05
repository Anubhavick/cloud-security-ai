# Frontend - Cloud Security AI Dashboard

React + Vite + Tailwind CSS frontend for the Oracle Hackathon Cloud Security AI project.

## Features

- **React 18** - Modern React with hooks
- **Vite** - Fast build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **Axios** - HTTP client for API calls
- **Responsive Design** - Works on desktop and mobile

## Local Development

### Prerequisites
- Node.js 18+ and npm

### Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment:
```bash
cp .env.example .env
# Edit .env and set VITE_API_URL to your backend URL
```

3. Run development server:
```bash
npm run dev
```

4. Open browser:
```
http://localhost:5173
```

## Production Build

Build for production:
```bash
npm run build
```

Preview production build:
```bash
npm run preview
```

The build output will be in the `dist/` directory.

## Project Structure

```
frontend/
├── index.html              # HTML entry point
├── package.json            # Dependencies and scripts
├── vite.config.js          # Vite configuration
├── tailwind.config.js      # Tailwind CSS configuration
├── postcss.config.js       # PostCSS configuration
├── .env.example            # Environment variables template
├── src/
│   ├── main.jsx           # Application entry point
│   ├── App.jsx            # Main App component
│   ├── index.css          # Global styles
│   ├── config.js          # API configuration
│   ├── components/        # React components
│   │   └── Dashboard.jsx  # Main dashboard component
│   └── services/          # Service layer
│       └── api.js         # API service
└── public/                # Static assets
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Configuration

### Environment Variables

Create a `.env` file with:

```env
VITE_API_URL=http://localhost:8000
```

For production deployment on OCI, update to:
```env
VITE_API_URL=http://<your-oci-instance-ip>:8000
```

## Deployment

### Deploy to OCI Compute Instance

After building the frontend:

1. Build the production bundle:
```bash
npm run build
```

2. Copy the `dist/` folder to your OCI instance:
```bash
scp -r dist/* opc@<instance-ip>:/var/www/html/
```

3. Set up a web server (Nginx or Apache) to serve the static files.

### Deploy with Docker (Optional)

Create a `Dockerfile`:
```dockerfile
FROM nginx:alpine
COPY dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Build and run:
```bash
docker build -t frontend .
docker run -p 80:80 frontend
```

## Features

### Dashboard
- **Model Information** - View current model details
- **Prediction Form** - Input features and get predictions
- **Real-time Results** - See prediction results with confidence scores
- **API Status** - Visual indicator of backend connection
- **Error Handling** - User-friendly error messages

### API Integration
- Health checks
- Model predictions
- Batch predictions
- Model information retrieval

## Customization

### Styling
- Edit `tailwind.config.js` to customize colors and theme
- Add custom CSS in `src/index.css`

### API Configuration
- Edit `src/config.js` to change API endpoints
- Update `src/services/api.js` to add new API methods

## Troubleshooting

### Cannot connect to backend
- Check that the backend is running
- Verify `VITE_API_URL` in `.env`
- Check CORS settings in the backend

### Build errors
- Clear node_modules: `rm -rf node_modules && npm install`
- Clear Vite cache: `rm -rf node_modules/.vite`
