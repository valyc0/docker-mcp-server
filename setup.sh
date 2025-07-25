#!/bin/bash

# Setup script for MCP Server environment
# Downloads repositories, configures directories, and sets up the environment
# Created: $(date)

# Set script directory and tmp directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$SCRIPT_DIR/tmp"

# Create tmp directory if it doesn't exist
mkdir -p "$TMP_DIR"

echo "Downloading repositories to: $TMP_DIR"

# Change to tmp directory
cd "$TMP_DIR"

# Download rest-chatbot-mcp repository
echo "Downloading rest-chatbot-mcp repository..."
if [ -d "rest-chatbot-mcp" ]; then
    echo "Directory rest-chatbot-mcp already exists. Removing it first..."
    rm -rf rest-chatbot-mcp
fi

git clone https://github.com/valyc0/rest-chatbot-mcp.git
if [ $? -eq 0 ]; then
    echo "✓ Successfully downloaded rest-chatbot-mcp"
else
    echo "✗ Failed to download rest-chatbot-mcp"
    exit 1
fi

# Download quarkus-mcp-servers-java-docker repository
echo "Downloading quarkus-mcp-servers-java-docker repository..."
if [ -d "quarkus-mcp-servers-java-docker" ]; then
    echo "Directory quarkus-mcp-servers-java-docker already exists. Removing it first..."
    rm -rf quarkus-mcp-servers-java-docker
fi

git clone https://github.com/valyc0/quarkus-mcp-servers-java-docker.git
if [ $? -eq 0 ]; then
    echo "✓ Successfully downloaded quarkus-mcp-servers-java-docker"
else
    echo "✗ Failed to download quarkus-mcp-servers-java-docker"
    exit 1
fi

# Move chatbot-ui directory to parent directory
echo "Moving chatbot-ui directory..."
if [ -d "rest-chatbot-mcp/chatbot-ui" ]; then
    # Remove existing chatbot-ui directory in parent if it exists
    if [ -d "../chatbot-ui" ]; then
        echo "Removing existing chatbot-ui directory in parent..."
        rm -rf "../chatbot-ui"
    fi
    
    # Move the chatbot-ui directory using relative paths
    mv "rest-chatbot-mcp/chatbot-ui" "../chatbot-ui"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully moved chatbot-ui to parent directory"
    else
        echo "✗ Failed to move chatbot-ui directory"
        exit 1
    fi
else
    echo "⚠ Warning: chatbot-ui directory not found in rest-chatbot-mcp"
fi

# Move rest-chatbot-mcp directory to parent and rename it to rest-mcp-server
echo "Moving rest-chatbot-mcp directory..."
if [ -d "rest-chatbot-mcp" ]; then
    # Remove existing rest-mcp-server directory in parent if it exists
    if [ -d "../rest-mcp-server" ]; then
        echo "Removing existing rest-mcp-server directory in parent..."
        rm -rf "../rest-mcp-server"
    fi
    
    # Move and rename the rest-chatbot-mcp directory using relative paths
    mv "rest-chatbot-mcp" "../rest-mcp-server"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully moved rest-chatbot-mcp to parent directory as rest-mcp-server"
    else
        echo "✗ Failed to move rest-chatbot-mcp directory"
        exit 1
    fi
else
    echo "⚠ Warning: rest-chatbot-mcp directory not found"
fi

# Move quarkus-mcp-servers-java-docker directory to parent
echo "Moving quarkus-mcp-servers-java-docker directory..."
if [ -d "quarkus-mcp-servers-java-docker" ]; then
    # Remove existing quarkus-mcp-servers-java-docker directory in parent if it exists
    if [ -d "../quarkus-mcp-servers-java-docker" ]; then
        echo "Removing existing quarkus-mcp-servers-java-docker directory in parent..."
        rm -rf "../quarkus-mcp-servers-java-docker"
    fi
    
    # Move the quarkus-mcp-servers-java-docker directory using relative paths
    mv "quarkus-mcp-servers-java-docker" "../quarkus-mcp-servers-java-docker"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully moved quarkus-mcp-servers-java-docker to parent directory"
    else
        echo "✗ Failed to move quarkus-mcp-servers-java-docker directory"
        exit 1
    fi
else
    echo "⚠ Warning: quarkus-mcp-servers-java-docker directory not found"
fi

# Setup JDK17 and build only JDBC MCP server JAR
echo "Setting up JDK17 and building JDBC MCP server..."

# Go back to script directory to find the moved quarkus directory
cd "$SCRIPT_DIR"

if [ -d "quarkus-mcp-servers-java-docker" ]; then
    cd "quarkus-mcp-servers-java-docker"
    
    # Download and setup JDK17 if not present
    if [ ! -d "jdk17" ]; then
        echo "Downloading JDK17..."
        
        # Detect architecture
        ARCH=$(uname -m)
        OS=$(uname -s)
        
        case "$ARCH" in
            x86_64|amd64) ARCH="x64" ;;
            aarch64|arm64) ARCH="aarch64" ;;
            *) echo "✗ Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        
        case "$OS" in
            Linux) OS="linux" ;;
            Darwin) OS="mac" ;;
            *) echo "✗ Unsupported OS: $OS"; exit 1 ;;
        esac
        
        # Download JDK17 from Eclipse Temurin
        JDK_VERSION="17.0.11"
        JDK_BUILD="9"
        JDK_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_VERSION}%2B${JDK_BUILD}/OpenJDK17U-jdk_${ARCH}_${OS}_hotspot_${JDK_VERSION}_${JDK_BUILD}.tar.gz"
        JDK_ARCHIVE="OpenJDK17U-jdk_${ARCH}_${OS}_hotspot_${JDK_VERSION}_${JDK_BUILD}.tar.gz"
        
        # Get absolute path of the quarkus directory (we are currently in it)
        QUARKUS_DIR=$(pwd)
        
        # Create temporary directory for JDK download
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        echo "Downloading from: $JDK_URL"
        if command -v wget >/dev/null 2>&1; then
            wget -O "$JDK_ARCHIVE" "$JDK_URL"
        elif command -v curl >/dev/null 2>&1; then
            curl -L -o "$JDK_ARCHIVE" "$JDK_URL"
        else
            echo "✗ wget or curl not found"
            exit 1
        fi
        
        if [ ! -f "$JDK_ARCHIVE" ]; then
            echo "✗ JDK download failed"
            exit 1
        fi
        
        # Extract JDK to target directory
        mkdir -p "$QUARKUS_DIR/jdk17"
        tar -xzf "$JDK_ARCHIVE" -C "$QUARKUS_DIR/jdk17" --strip-components=1
        
        # Cleanup
        rm -rf "$TEMP_DIR"
        
        # Go back to quarkus directory and verify
        cd "$QUARKUS_DIR"
        
        if [ ! -f "jdk17/bin/java" ]; then
            echo "✗ JDK extraction failed"
            exit 1
        fi
        
        echo "✓ JDK17 downloaded and extracted"
    fi
    
    # Build only JDBC module
    echo "Building JDBC MCP server..."
    export JAVA_HOME="$(pwd)/jdk17"
    export PATH="$JAVA_HOME/bin:$PATH"
    
    # Install Maven if not available
    if ! command -v mvn >/dev/null 2>&1; then
        echo "Installing Maven..."
        MAVEN_VERSION="3.9.5"
        MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
        MAVEN_ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
        
        # Create temporary directory for Maven download
        MAVEN_TEMP_DIR=$(mktemp -d)
        cd "$MAVEN_TEMP_DIR"
        
        echo "Downloading Maven from: $MAVEN_URL"
        if command -v wget >/dev/null 2>&1; then
            wget -O "$MAVEN_ARCHIVE" "$MAVEN_URL"
        elif command -v curl >/dev/null 2>&1; then
            curl -L -o "$MAVEN_ARCHIVE" "$MAVEN_URL"
        else
            echo "✗ wget or curl not found"
            exit 1
        fi
        
        if [ ! -f "$MAVEN_ARCHIVE" ]; then
            echo "✗ Maven download failed"
            exit 1
        fi
        
        # Extract Maven to the quarkus directory
        mkdir -p "$(pwd)/maven"
        tar -xzf "$MAVEN_ARCHIVE" -C "$(pwd)/maven" --strip-components=1
        
        # Move Maven to quarkus directory
        CURRENT_DIR=$(pwd)
        cd "$QUARKUS_DIR"
        cp -r "$CURRENT_DIR/maven" ./maven
        
        # Cleanup
        rm -rf "$MAVEN_TEMP_DIR"
        
        # Add Maven to PATH
        export PATH="$(pwd)/maven/bin:$PATH"
        
        echo "✓ Maven installed"
    fi
    
    cd jdbc
    
    # Use Maven
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ] && [ -f "target/mcp-server-jdbc-universal-999-SNAPSHOT.jar" ]; then
        echo "✓ Successfully built mcp-server-jdbc-universal-999-SNAPSHOT.jar"
        echo "✓ JAR file created: $(pwd)/target/mcp-server-jdbc-universal-999-SNAPSHOT.jar"
    else
        echo "✗ Failed to build JDBC MCP server"
        exit 1
    fi
    
    # Return to the script directory
    cd "$SCRIPT_DIR"
else
    echo "⚠ Warning: quarkus-mcp-servers-java-docker directory not found"
fi

# Go back to script directory for final operations
cd "$SCRIPT_DIR"

# Copy .env.example to .env in rest-mcp-server directory
echo "Setting up environment configuration..."
if [ -d "rest-mcp-server" ] && [ -f "rest-mcp-server/.env.example" ]; then
    cp "rest-mcp-server/.env.example" "rest-mcp-server/.env"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully copied .env.example to .env"
        echo ""
        echo "⚠ IMPORTANT: Remember to edit rest-mcp-server/.env and add your API keys:"
        echo "  - OPENROUTER_API_KEY=your_openrouter_api_key_here"
        echo "  - GOOGLE_API_KEY=your_google_api_key_here"
    else
        echo "✗ Failed to copy .env.example to .env"
    fi
else
    echo "⚠ Warning: .env.example not found in rest-mcp-server directory"
fi

# Copy rule.txt to rest-mcp-server/prompts/default.txt
echo "Setting up default prompt..."
if [ -f "$SCRIPT_DIR/rule.txt" ] && [ -d "rest-mcp-server" ]; then
    # Create prompts directory if it doesn't exist
    mkdir -p "rest-mcp-server/prompts"
    
    cp "$SCRIPT_DIR/rule.txt" "rest-mcp-server/prompts/default.txt"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully copied rule.txt to rest-mcp-server/prompts/default.txt"
    else
        echo "✗ Failed to copy rule.txt to default.txt"
    fi
else
    echo "⚠ Warning: rule.txt not found or rest-mcp-server directory missing"
fi

# Replace 1mcp-agent configuration with jdbc-oracle configuration
echo "Updating MCP configuration..."
./replace-mcp.sh
if [ $? -eq 0 ]; then
    echo "✓ MCP configuration update completed"
else
    echo "✗ Failed to update MCP configuration"
    exit 1
fi

echo ""
echo "Download and setup completed successfully!"
echo "All directories moved to parent:"
echo "  - $SCRIPT_DIR/chatbot-ui"
echo "  - $SCRIPT_DIR/rest-mcp-server"
echo "  - $SCRIPT_DIR/quarkus-mcp-servers-java-docker"
echo "JDBC MCP server JAR built: quarkus-mcp-servers-java-docker/jdbc/target/mcp-server-jdbc-universal-999-SNAPSHOT.jar"
echo "Environment file (.env) created in rest-mcp-server directory."
echo "Default prompt (rule.txt) copied to rest-mcp-server/prompts/default.txt."
echo "MCP configuration updated: 1mcp-agent replaced with jdbc-oracle."
echo ""
echo "⚠ NEXT STEPS:"
echo "1. Edit rest-mcp-server/.env and add your API keys"
echo "2. Run: ./start.sh"
echo ""
echo "tmp directory is now empty and can be removed if needed."
