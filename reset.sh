#!/bin/bash

# Script to reset/clean up all directories created by setup.sh
# This will remove all downloaded and moved directories

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧹 Resetting workspace - removing all downloaded directories..."
echo "Script directory: $SCRIPT_DIR"
echo ""

# Function to safely remove directory
remove_directory() {
    local dir_path="$1"
    local dir_name="$2"
    
    if [ -d "$dir_path" ]; then
        echo "Removing $dir_name directory: $dir_path"
        sudo rm -rf "$dir_path"
        if [ $? -eq 0 ]; then
            echo "✓ Successfully removed $dir_name"
        else
            echo "✗ Failed to remove $dir_name"
            return 1
        fi
    else
        echo "ℹ $dir_name directory not found (already clean)"
    fi
}

# Remove chatbot-ui directory
remove_directory "$SCRIPT_DIR/chatbot-ui" "chatbot-ui"

# Remove rest-mcp-server directory
remove_directory "$SCRIPT_DIR/rest-mcp-server" "rest-mcp-server"

# Remove quarkus-mcp-servers-java-docker directory
remove_directory "$SCRIPT_DIR/quarkus-mcp-servers-java-docker" "quarkus-mcp-servers-java-docker"

# Remove tmp directory and all its contents
remove_directory "$SCRIPT_DIR/tmp" "tmp"

echo ""
echo "🎯 Reset completed!"
echo "All directories created by setup.sh have been removed:"
echo "  - chatbot-ui"
echo "  - rest-mcp-server" 
echo "  - quarkus-mcp-servers-java-docker"
echo "  - tmp"
echo ""
echo "You can now run setup.sh again for a fresh setup."
echo ""
echo "⚠ IMPORTANT REMINDER:"
echo "After running setup.sh, don't forget to edit rest-mcp-server/.env and add your API keys:"
echo "  - OPENROUTER_API_KEY=your_openrouter_api_key_here"
echo "  - GOOGLE_API_KEY=your_google_api_key_here"
