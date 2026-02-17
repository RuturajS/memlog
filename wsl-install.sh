#!/bin/bash

# Quick WSL Build and Install Script for Memlog
# Run this in WSL to build and install memlog locally

set -e

echo "🚀 Building Memlog in WSL..."
echo ""

# Navigate to project directory
cd /mnt/c/Users/rutur/OneDrive/Desktop/Ai-Projects/memlog/memlog

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed!"
    echo ""
    echo "Install Go with:"
    echo "  wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz"
    echo "  sudo rm -rf /usr/local/go"
    echo "  sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz"
    echo "  echo 'export PATH=\$PATH:/usr/local/go/bin' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    exit 1
fi

echo "✓ Go version: $(go version)"
echo ""

# Download dependencies
echo "📦 Downloading dependencies..."
go mod download
go mod tidy
echo "✓ Dependencies ready"
echo ""

# Build
echo "🔨 Building memlog..."
mkdir -p build
go build -o build/memlog ./cmd/memlog
chmod +x build/memlog
echo "✓ Build complete!"
echo ""

# Test
echo "🧪 Testing build..."
./build/memlog --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Build test passed"
else
    echo "✗ Build test failed"
    exit 1
fi
echo ""

# Install to /usr/local/bin
echo "📥 Installing to /usr/local/bin..."
sudo cp build/memlog /usr/local/bin/memlog
sudo chmod +x /usr/local/bin/memlog
echo "✓ Installed!"
echo ""

# Create log directory
mkdir -p ~/.memlog/logs
echo "✓ Created log directory"
echo ""

echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! 🎉          ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "Try it out:"
echo "  memlog exec 'echo Hello Memlog!'"
echo "  memlog logs --last 5"
echo "  memlog stats"
echo ""
