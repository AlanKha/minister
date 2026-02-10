#!/bin/bash

# Minister Development Startup Script
# Starts the Dart server and Flutter macOS app

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Starting Minister Development Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker ps > /dev/null 2>&1; then
    echo "⏳ Docker daemon not running. Opening Docker.app..."
    open /Applications/Docker.app
    echo "⏳ Waiting for Docker to start (this takes a moment)..."
    sleep 10

    # Check again
    if ! docker ps > /dev/null 2>&1; then
        echo "❌ Docker daemon failed to start. Please open Docker.app manually."
        exit 1
    fi
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Install from https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Start the server in Docker
echo ""
echo "📦 Starting Dart server in Docker..."
echo "   Server will be available at http://localhost:3000"
cd "$PROJECT_ROOT"
docker-compose up -d

# Wait for server to be healthy
echo "⏳ Waiting for server to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -f http://localhost:3000/api/accounts > /dev/null 2>&1; then
        echo "✅ Server is ready!"
        break
    fi
    sleep 1
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "⚠️  Server may not be responding. Check with: docker-compose logs"
fi

# Start the Flutter app
echo ""
echo "📱 Starting Flutter macOS app..."
echo ""
cd "$PROJECT_ROOT/app"
flutter clean > /dev/null 2>&1 || true
flutter pub get > /dev/null 2>&1
flutter run -d macos

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Development environment started!"
echo ""
echo "To stop everything:"
echo "  1. Close the macOS app (⌘Q)"
echo "  2. Run: docker-compose down"
