# 🔍 Memlog - Production-Ready Command Logging Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go)](https://go.dev/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey)](https://github.com/RuturajS/memlog)

**Memlog** is a lightweight, cross-platform command logging tool that captures every shell command you execute with comprehensive metadata. Perfect for auditing, debugging, and analyzing your command-line workflow.

##  Features

-  **Zero-overhead logging** - Async writes, <20MB memory footprint
-  **Security-first** - Auto-redacts sensitive keywords (passwords, tokens, secrets)
-  **Rich metadata** - Captures timestamp, user, host, directory, exit code, output, and duration
-  **Powerful filtering** - Search by user, command, date, exit code, or grep through output
-  **Beautiful HTML reports** - Generate visual analytics with charts and statistics
-  **Automatic log rotation** - Compress and clean old logs automatically
-  **Cross-platform** - Works on Linux, macOS, and Windows (PowerShell)
-  **Single binary** - No dependencies, easy installation

##  Installation

### Linux / macOS

```bash
curl -sSL https://raw.githubusercontent.com/RuturajS/memlog/main/scripts/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/RuturajS/memlog/main/scripts/install.ps1 | iex
```

### Manual Installation

Download the latest binary from [Releases](https://github.com/RuturajS/memlog/releases) and add it to your PATH.

##  Quick Start

### Execute and Log a Command

```bash
memlog exec "ls -la"
memlog exec "git status"
```

### View Recent Commands

```bash
# Last 10 commands
memlog logs --last 10

# Today's commands
memlog logs --today

# Failed commands only
memlog logs --failed

# Commands from specific user
memlog logs --user=ruturaj

# Search in command/output
memlog logs --grep="error"
```

### View Detailed Log Entry

```bash
memlog show 123
```

### Generate Statistics

```bash
memlog stats
```

Output:
```
═══════════════════════════════════════════════════════════
                    MEMLOG STATISTICS
═══════════════════════════════════════════════════════════

Total Commands:        1,247
Failed Commands:       23
Failure Rate:          1.84%
Most Used Command:     git (342 times)
Average Duration:      127ms
Last Command:          memlog stats
Last Executed:         2026-02-17T20:30:15+05:30
═══════════════════════════════════════════════════════════
```

### Generate HTML Report

```bash
# Generate report for last month
memlog report --from=2026-01-01 --to=2026-02-01

# Opens: report-2026-02.html
```

### Clean Old Logs

```bash
# Clean logs older than 30 days
memlog clean --days=30

# Rotate logs larger than 50MB
memlog clean --max-size=50
```

##  Advanced Usage

### Filtering Examples

```bash
# Commands since a specific date
memlog logs --since=2026-02-01

# Commands containing "docker"
memlog logs --command="docker"

# Sort by duration (slowest first)
memlog logs --sort=duration --last 10

# Combine filters
memlog logs --user=ruturaj --failed --today
```

### Log Format

Logs are stored in `~/.memlog/logs/memlog-YYYY-MM-DD.jsonl`:

```json
{
  "id": 123,
  "timestamp": "2026-02-17T20:30:15+05:30",
  "user": "ruturaj",
  "host": "laptop",
  "cwd": "/home/ruturaj/projects",
  "command": "git commit -m 'Initial commit'",
  "exit_code": 0,
  "stdout": "[main abc1234] Initial commit\n 1 file changed, 10 insertions(+)",
  "stderr": "",
  "duration_ms": 245
}
```

##  Security Features

Memlog automatically redacts commands containing sensitive keywords:

- `password`
- `secret`
- `token`
- `api_key`
- `apikey`

Example:
```bash
memlog exec "export API_KEY=secret123"
# Logged as: [REDACTED - contains sensitive keywords]
```

### Preventing Recursive Logging

Memlog sets the `MEMLOG_ACTIVE` environment variable to prevent logging its own commands.

## HTML Report Features

Generated reports include:

-  Total commands executed
-  Failed commands count
-  Success rate percentage
-  Most used commands (top 10)
-  Activity by hour (bar chart)
-  Top directories used
-  Longest running commands

## 🛠️ Development

### Build from Source

```bash
# Clone repository
git clone https://github.com/RuturajS/memlog.git
cd memlog

# Download dependencies
go mod download

# Build
make build

# Run tests
make test

# Build for all platforms
make release
```

### Project Structure

```
memlog/
├── cmd/memlog/          # Main CLI application
├── internal/
│   ├── logger/          # Async logging engine
│   ├── executor/        # Command execution
│   ├── storage/         # Log reading & filtering
│   ├── cleanup/         # Log rotation & cleanup
│   └── report/          # HTML report generation
├── scripts/             # Installation scripts
├── templates/           # HTML templates
└── Makefile            # Build automation
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Cobra](https://github.com/spf13/cobra) for CLI framework
- Inspired by command history tools and shell auditing needs

## 📧 Contact

**Ruturaj Sharbidre** - [@RuturajS](https://github.com/RuturajS)

Project Link: [https://github.com/RuturajS/memlog](https://github.com/RuturajS/memlog)

---

**⭐ Star this repository if you find it useful!**