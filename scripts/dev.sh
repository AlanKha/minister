#!/bin/bash

# Minister Development Startup Script
# Starts the Dart server and Flutter app on the specified platform
# Usage: ./scripts/dev.sh [macos|web|ios]

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Parse platform argument (default to macos)
PLATFORM="${1:-macos}"

# Validate platform
case "$PLATFORM" in
    macos|web|ios)
        ;;
    *)
        echo "❌ Invalid platform: $PLATFORM"
        echo "Usage: ./scripts/dev.sh [macos|web|ios]"
        exit 1
        ;;
esac

echo "🚀 Starting Minister Development Environment ($PLATFORM)"
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

# Setup cleanup on exit
cleanup() {
    echo ""
    echo "🧹 Shutting down development environment..."
    cd "$PROJECT_ROOT"
    docker-compose down
}
trap cleanup EXIT

docker-compose up --build -d

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
cd "$PROJECT_ROOT/app"
flutter clean > /dev/null 2>&1 || true
flutter pub get > /dev/null 2>&1

case "$PLATFORM" in
    macos)
        echo "📱 Starting Flutter macOS app..."
        echo ""
        flutter run -d macos
        ;;
    web)
        echo "🌐 Starting Flutter web app..."
        echo ""
        flutter run -d chrome
        ;;
    ios)
        echo "📱 Starting Flutter iOS app..."
        echo ""
        # Find available iOS devices
        IOS_DEVICES=$(flutter devices --machine | grep -o '"id":"[^"]*","isSupported":true,"targetPlatform":"ios"' | grep -o '"id":"[^"]*"' | cut -d'"' -f4 || true)

        if [ -z "$IOS_DEVICES" ]; then
            echo "❌ No iOS devices found. Please:"
            echo "   1. Connect an iPhone/iPad via USB, or"
            echo "   2. Enable wireless debugging on your device"
            echo "   3. Make sure your device is on the same network"
            exit 1
        fi

        # Use the first available iOS device
        FIRST_IOS_DEVICE=$(echo "$IOS_DEVICES" | head -n 1)
        echo "Using device: $FIRST_IOS_DEVICE"
        flutter run -d "$FIRST_IOS_DEVICE"
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Development environment closed!"
echo ""
