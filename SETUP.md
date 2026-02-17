# 🚀 Development Setup Guide

This guide will help you set up the development environment for Memlog.

## Prerequisites

### Install Go

#### Windows
1. Download Go from [https://go.dev/dl/](https://go.dev/dl/)
2. Run the installer (e.g., `go1.21.6.windows-amd64.msi`)
3. Verify installation:
   ```powershell
   go version
   ```

#### Linux
```bash
wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
go version
```

#### macOS
```bash
brew install go
go version
```

## Building the Project

### 1. Clone the Repository

```bash
git clone https://github.com/RuturajS/memlog.git
cd memlog
```

### 2. Download Dependencies

```bash
go mod download
go mod tidy
```

### 3. Build for Your Platform

#### Using Make (Linux/macOS)
```bash
make build
```

#### Using Make on Windows (with Make installed)
```bash
make build
```

#### Manual Build (All Platforms)
```bash
go build -o build/memlog ./cmd/memlog
```

On Windows:
```powershell
go build -o build/memlog.exe ./cmd/memlog
```

### 4. Run the Binary

```bash
./build/memlog --help
```

On Windows:
```powershell
.\build\memlog.exe --help
```

## Testing

### Run All Tests
```bash
go test ./...
```

### Run Tests with Coverage
```bash
go test -cover ./...
```

### Run Tests Verbosely
```bash
go test -v ./...
```

## Cross-Platform Builds

### Build for All Platforms

Using Make:
```bash
make release
```

Manual:
```bash
# Linux amd64
GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o build/memlog-linux-amd64 ./cmd/memlog

# Linux arm64
GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o build/memlog-linux-arm64 ./cmd/memlog

# macOS amd64
GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o build/memlog-darwin-amd64 ./cmd/memlog

# macOS arm64 (Apple Silicon)
GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w" -o build/memlog-darwin-arm64 ./cmd/memlog

# Windows amd64
GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o build/memlog-windows-amd64.exe ./cmd/memlog
```

## Development Workflow

### 1. Make Changes
Edit the code in your favorite editor.

### 2. Format Code
```bash
go fmt ./...
```

### 3. Run Locally
```bash
go run ./cmd/memlog exec "echo Hello"
go run ./cmd/memlog logs --last 5
go run ./cmd/memlog stats
```

### 4. Build and Test
```bash
make build
./build/memlog exec "ls -la"
./build/memlog logs --last 10
```

## Releasing

### 1. Update Version
Update version in:
- `CHANGELOG.md`
- `README.md` (if needed)

### 2. Commit Changes
```bash
git add .
git commit -m "Release v1.0.0"
git push origin main
```

### 3. Create Tag
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 4. GitHub Actions
The GitHub Actions workflow will automatically:
- Build binaries for all platforms
- Create checksums
- Create a GitHub Release
- Upload all artifacts

## Troubleshooting

### Go Not Found
Make sure Go is installed and in your PATH:
```bash
echo $PATH  # Linux/macOS
echo $env:Path  # Windows PowerShell
```

### Module Errors
```bash
go mod tidy
go mod download
```

### Build Errors
Clean and rebuild:
```bash
make clean
make build
```

Or manually:
```bash
rm -rf build/
go build -o build/memlog ./cmd/memlog
```

### Permission Denied (Linux/macOS)
```bash
chmod +x build/memlog
```

## Project Structure

```
memlog/
├── .github/
│   └── workflows/
│       └── release.yml          # GitHub Actions for releases
├── cmd/
│   └── memlog/
│       └── main.go              # CLI entry point
├── internal/
│   ├── logger/
│   │   └── logger.go            # Async logging engine
│   ├── executor/
│   │   └── executor.go          # Command execution
│   ├── storage/
│   │   └── storage.go           # Log reading & filtering
│   ├── cleanup/
│   │   └── cleanup.go           # Log rotation & cleanup
│   └── report/
│       └── report.go            # HTML report generation
├── scripts/
│   ├── install.sh               # Linux/macOS installer
│   └── install.ps1              # Windows installer
├── templates/
│   └── report.html              # HTML report template
├── build/                       # Build output (gitignored)
├── go.mod                       # Go module definition
├── go.sum                       # Go module checksums
├── Makefile                     # Build automation
├── README.md                    # Main documentation
├── CHANGELOG.md                 # Version history
├── LICENSE                      # MIT License
└── .gitignore                   # Git ignore rules
```

## Next Steps

1. **Install Go** if you haven't already
2. **Run `go mod download`** to get dependencies
3. **Build the project** with `make build` or `go build`
4. **Test locally** with `./build/memlog exec "echo test"`
5. **Push to GitHub** and create releases

## Questions?

Open an issue on GitHub: [https://github.com/RuturajS/memlog/issues](https://github.com/RuturajS/memlog/issues)
