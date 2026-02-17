.PHONY: build clean release install test

BINARY_NAME=memlog
VERSION?=1.0.0
BUILD_DIR=build
MAIN_PATH=./cmd/memlog

# Build for current platform
build:
	@echo "Building $(BINARY_NAME)..."
	@go build -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PATH)
	@echo "✓ Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

# Build for all platforms
release:
	@echo "Building release binaries..."
	@mkdir -p $(BUILD_DIR)
	
	@echo "Building for Linux amd64..."
	@GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 $(MAIN_PATH)
	
	@echo "Building for Linux arm64..."
	@GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 $(MAIN_PATH)
	
	@echo "Building for macOS amd64..."
	@GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 $(MAIN_PATH)
	
	@echo "Building for macOS arm64..."
	@GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 $(MAIN_PATH)
	
	@echo "Building for Windows amd64..."
	@GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe $(MAIN_PATH)
	
	@echo "✓ All release binaries built in $(BUILD_DIR)/"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "✓ Clean complete"

# Install locally
install: build
	@echo "Installing $(BINARY_NAME)..."
	@cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/
	@echo "✓ Installed to /usr/local/bin/$(BINARY_NAME)"

# Run tests
test:
	@echo "Running tests..."
	@go test -v ./...

# Download dependencies
deps:
	@echo "Downloading dependencies..."
	@go mod download
	@go mod tidy
	@echo "✓ Dependencies ready"

# Run locally
run:
	@go run $(MAIN_PATH)

# Format code
fmt:
	@echo "Formatting code..."
	@go fmt ./...
	@echo "✓ Code formatted"

# Lint code
lint:
	@echo "Linting code..."
	@golangci-lint run ./...
	@echo "✓ Lint complete"
