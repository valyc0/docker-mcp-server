#!/bin/bash

# Script to replace 1mcp-agent configuration with jdbc-oracle configuration
# Usage: ./replace-mcp.sh

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Replacing 1mcp-agent with jdbc-oracle configuration..."

# Check if required files exist
if [ ! -f "$SCRIPT_DIR/rest-mcp-server/mcp_config.json" ]; then
    echo "✗ Error: mcp_config.json not found in rest-mcp-server directory"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/mcp-conf-oracle.txt" ]; then
    echo "✗ Error: mcp-conf-oracle.txt not found"
    exit 1
fi

# Replace the configuration using Python
python3 -c "
import json
import sys

# Read the oracle configuration from the text file
with open('$SCRIPT_DIR/mcp-conf-oracle.txt', 'r') as f:
    oracle_config_text = f.read().strip()

# Read the current mcp_config.json
with open('$SCRIPT_DIR/rest-mcp-server/mcp_config.json', 'r') as f:
    config = json.load(f)

# Remove 1mcp-agent if it exists
if '1mcp-agent' in config.get('mcpServers', {}):
    del config['mcpServers']['1mcp-agent']
    print('Removed 1mcp-agent configuration')
else:
    print('1mcp-agent configuration not found (already clean)')

# Parse the oracle configuration text and add it
# The text file contains just the key-value pair, so we need to parse it manually
oracle_config_text = oracle_config_text.replace('\"jdbc-oracle\":', '').strip()
if oracle_config_text.startswith('{') and oracle_config_text.endswith('}'):
    oracle_config = json.loads(oracle_config_text)
    config['mcpServers']['jdbc-oracle'] = oracle_config
    print('Added jdbc-oracle configuration')
else:
    print('Error: Invalid oracle configuration format')
    sys.exit(1)

# Write the updated configuration back
with open('$SCRIPT_DIR/rest-mcp-server/mcp_config.json', 'w') as f:
    json.dump(config, f, indent=2)

print('MCP configuration updated successfully')
"

if [ $? -eq 0 ]; then
    echo "✓ Successfully replaced 1mcp-agent with jdbc-oracle configuration"
else
    echo "✗ Failed to replace 1mcp-agent configuration"
    exit 1
fi
