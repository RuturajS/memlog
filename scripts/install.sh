#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Memlog Installer v1.0.0          ║${NC}"
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo ""

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo -e "${YELLOW}Detected OS: $OS${NC}"
echo -e "${YELLOW}Detected Architecture: $ARCH${NC}"
echo ""

# GitHub release URL (update with your username)
GITHUB_USER="RuturajS"
REPO="memlog"
VERSION="latest"
BINARY_NAME="memlog-${OS}-${ARCH}"

if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/${GITHUB_USER}/${REPO}/releases/latest/download/${BINARY_NAME}"
else
    DOWNLOAD_URL="https://github.com/${GITHUB_USER}/${REPO}/releases/download/${VERSION}/${BINARY_NAME}"
fi

echo -e "${YELLOW}Downloading memlog...${NC}"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

if command -v curl &> /dev/null; then
    curl -L -o memlog "$DOWNLOAD_URL"
elif command -v wget &> /dev/null; then
    wget -O memlog "$DOWNLOAD_URL"
else
    echo -e "${RED}Error: curl or wget is required${NC}"
    exit 1
fi

# Make executable
chmod +x memlog

# Install to /usr/local/bin
echo -e "${YELLOW}Installing to /usr/local/bin...${NC}"
sudo mv memlog /usr/local/bin/memlog

# Create log directory
echo -e "${YELLOW}Creating log directory...${NC}"
mkdir -p "$HOME/.memlog/logs"

# Add shell hooks
echo -e "${YELLOW}Setting up shell hooks...${NC}"

HOOK_FUNCTION='
# Memlog hook
memlog_preexec() {
    if [ -n "$BASH_COMMAND" ] && [ "$BASH_COMMAND" != "memlog_preexec" ]; then
        memlog exec "$BASH_COMMAND" &>/dev/null &
    fi
}

# Prevent recursive logging
if [ -z "$MEMLOG_ACTIVE" ]; then
    export MEMLOG_ACTIVE=1
fi
'

# Bash
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "memlog_preexec" "$HOME/.bashrc"; then
        echo "$HOOK_FUNCTION" >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added hook to .bashrc${NC}"
    fi
fi

# Zsh
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "memlog_preexec" "$HOME/.zshrc"; then
        echo "$HOOK_FUNCTION" >> "$HOME/.zshrc"
        echo 'preexec() { memlog_preexec; }' >> "$HOME/.zshrc"
        echo -e "${GREEN}✓ Added hook to .zshrc${NC}"
    fi
fi

# Cleanup
cd - > /dev/null
rm -rf "$TMP_DIR"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete! 🎉          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Usage:${NC}"
echo "  memlog exec 'your command'  - Execute and log a command"
echo "  memlog logs --last 10       - View last 10 commands"
echo "  memlog stats                - View statistics"
echo "  memlog report               - Generate HTML report"
echo ""
echo -e "${YELLOW}Restart your shell or run:${NC}"
echo "  source ~/.bashrc  (or ~/.zshrc)"
echo ""
