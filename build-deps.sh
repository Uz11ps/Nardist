#!/bin/bash

set -e

echo "🔨 Building dependency images (one-time setup)..."

# Собираем образ с зависимостями для backend
echo "📦 Building backend dependencies..."
docker build -f backend/Dockerfile.deps -t nardist-backend-deps:latest ./backend

# Собираем образ с зависимостями для frontend
echo "📦 Building frontend dependencies..."
docker build -f frontend/Dockerfile.deps -t nardist-frontend-deps:latest ./frontend

echo "✅ Dependency images built successfully!"
echo "💡 Now you can build the main images faster - they will use these cached dependencies"

