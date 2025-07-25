#!/bin/bash

# Script to start MCP Server environment and follow logs
# Starts Docker Compose services and follows mcp-server logs

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting MCP Server environment..."
echo "Script directory: $SCRIPT_DIR"
echo ""

# Check if docker-compose.yml exists
if [ ! -f "$SCRIPT_DIR/docker-compose.yml" ]; then
    echo "✗ Error: docker-compose.yml not found in $SCRIPT_DIR"
    echo "Make sure you are in the correct directory and have run setup.sh first."
    exit 1
fi

# Check if .env file exists in rest-mcp-server
if [ ! -f "$SCRIPT_DIR/rest-mcp-server/.env" ]; then
    echo "⚠ Warning: .env file not found in rest-mcp-server directory"
    echo "Make sure you have configured your API keys in rest-mcp-server/.env"
    echo "You can copy from .env.example and add your keys."
    echo ""
    read -p "Do you want to continue anyway? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Aborted. Please configure your .env file first."
        exit 1
    fi
fi

# Start Docker Compose services in detached mode
echo "Starting Docker Compose services..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo "✓ Docker Compose services started successfully"
    echo ""
    echo "📊 Service status:"
    docker-compose ps
    echo ""
    echo "📋 Following mcp-server logs (press Ctrl+C to stop following logs)..."
    echo "Services will continue running in the background."
    echo ""
    
    # Follow mcp-server logs
    docker-compose logs -f mcp-server
else
    echo "✗ Failed to start Docker Compose services"
    echo ""
    echo "📋 Checking service status:"
    docker-compose ps
    echo ""
    echo "📋 Recent logs:"
    docker-compose logs --tail=20
    exit 1
fi
