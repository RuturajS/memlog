#!/bin/bash

# Memlog Build Script for WSL
# This script automates the build process in WSL

set -e

echo "╔═══════════════════════════════════════╗"
echo "║     Memlog Build Script (WSL)        ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${RED}Error: Go is not installed!${NC}"
    echo ""
    echo "Install Go with:"
    echo "  wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz"
    echo "  sudo rm -rf /usr/local/go"
    echo "  sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz"
    echo "  echo 'export PATH=\$PATH:/usr/local/go/bin' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    exit 1
fi

echo -e "${GREEN}✓ Go is installed: $(go version)${NC}"
echo ""

# Download dependencies
echo -e "${YELLOW}Downloading dependencies...${NC}"
go mod download
go mod tidy
echo -e "${GREEN}✓ Dependencies ready${NC}"
echo ""

# Build for current platform (Linux)
echo -e "${YELLOW}Building for Linux (WSL)...${NC}"
mkdir -p build
go build -o build/memlog ./cmd/memlog
chmod +x build/memlog
echo -e "${GREEN}✓ Build complete: build/memlog${NC}"
echo ""

# Test the build
echo -e "${YELLOW}Testing build...${NC}"
./build/memlog --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build test passed${NC}"
else
    echo -e "${RED}✗ Build test failed${NC}"
    exit 1
fi
echo ""

# Ask if user wants to build for all platforms
echo -e "${YELLOW}Build for all platforms? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo -e "${YELLOW}Building for all platforms...${NC}"
    
    echo "  → Linux amd64..."
    GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o build/memlog-linux-amd64 ./cmd/memlog
    
    echo "  → Linux arm64..."
    GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o build/memlog-linux-arm64 ./cmd/memlog
    
    echo "  → macOS amd64..."
    GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o build/memlog-darwin-amd64 ./cmd/memlog
    
    echo "  → macOS arm64..."
    GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w" -o build/memlog-darwin-arm64 ./cmd/memlog
    
    echo "  → Windows amd64..."
    GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o build/memlog-windows-amd64.exe ./cmd/memlog
    
    echo -e "${GREEN}✓ All platform builds complete${NC}"
    echo ""
    
    # Create checksums
    echo -e "${YELLOW}Creating checksums...${NC}"
    cd build
    sha256sum memlog-* > checksums.txt
    cd ..
    echo -e "${GREEN}✓ Checksums created${NC}"
fi

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║        Build Complete! 🎉            ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo -e "${YELLOW}Quick Test:${NC}"
echo "  ./build/memlog exec 'echo Hello Memlog!'"
echo "  ./build/memlog logs --last 5"
echo "  ./build/memlog stats"
echo ""
echo -e "${YELLOW}Build artifacts:${NC}"
ls -lh build/
echo ""
