#!/bin/bash

# Script to stop MCP Server environment
# Stops Docker Compose services gracefully

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🛑 Stopping MCP Server environment..."
echo "Script directory: $SCRIPT_DIR"
echo ""

# Check if docker-compose.yml exists
if [ ! -f "$SCRIPT_DIR/docker-compose.yml" ]; then
    echo "✗ Error: docker-compose.yml not found in $SCRIPT_DIR"
    echo "Make sure you are in the correct directory."
    exit 1
fi

# Stop Docker Compose services
echo "Stopping Docker Compose services..."
docker-compose down

if [ $? -eq 0 ]; then
    echo "✓ Docker Compose services stopped successfully"
    echo ""
    echo "📊 Service status:"
    docker-compose ps
    echo ""
    echo "🎯 All services have been stopped."
    echo "To start again, run: ./start.sh"
else
    echo "✗ Failed to stop Docker Compose services"
    echo ""
    echo "📊 Current service status:"
    docker-compose ps
    echo ""
    echo "📋 Recent logs:"
    docker-compose logs --tail=10
    exit 1
fi
