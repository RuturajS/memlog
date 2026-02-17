# Memlog Quick Reference

## Installation

```bash
# Linux/macOS
curl -sSL https://raw.githubusercontent.com/RuturajS/memlog/main/scripts/install.sh | bash

# Windows
iwr -useb https://raw.githubusercontent.com/RuturajS/memlog/main/scripts/install.ps1 | iex
```

## Basic Commands

| Command | Description |
|---------|-------------|
| `memlog exec "command"` | Execute and log a command |
| `memlog logs` | View all logged commands |
| `memlog show <id>` | View details of a specific log entry |
| `memlog stats` | Display command statistics |
| `memlog clean` | Clean old logs |
| `memlog report` | Generate HTML report |

## Filtering Options

### View Logs

```bash
# Last N commands
memlog logs --last 10

# Today's commands
memlog logs --today

# Failed commands only
memlog logs --failed

# Filter by user
memlog logs --user=ruturaj

# Filter by command
memlog logs --command="git"

# Search in command/output
memlog logs --grep="error"

# Commands since date
memlog logs --since=2026-02-01

# Combine filters
memlog logs --user=ruturaj --failed --today
```

### Sorting

```bash
# Sort by time (default)
memlog logs --sort=time

# Sort by duration (slowest first)
memlog logs --sort=duration

# Sort by exit code
memlog logs --sort=exit
```

## Cleanup

```bash
# Clean logs older than 30 days (default)
memlog clean

# Clean logs older than 15 days
memlog clean --days=15

# Rotate logs larger than 50MB
memlog clean --max-size=50

# Combine options
memlog clean --days=7 --max-size=100
```

## Reports

```bash
# Generate report for last month
memlog report

# Custom date range
memlog report --from=2026-01-01 --to=2026-02-01
```

## Log Entry Details

```bash
# View full details of log entry #123
memlog show 123
```

Output includes:
- Timestamp
- User and hostname
- Working directory
- Full command
- Exit code
- Execution duration
- Standard output
- Standard error

## Statistics

```bash
memlog stats
```

Shows:
- Total commands executed
- Failed commands count
- Failure rate
- Most used command
- Average execution time
- Last executed command

## Log File Location

```
~/.memlog/logs/memlog-YYYY-MM-DD.jsonl
```

## Log Entry Format

```json
{
  "id": 123,
  "timestamp": "2026-02-17T20:30:15+05:30",
  "user": "ruturaj",
  "host": "laptop",
  "cwd": "/home/ruturaj/projects",
  "command": "git commit -m 'Initial commit'",
  "exit_code": 0,
  "stdout": "[main abc1234] Initial commit\n 1 file changed",
  "stderr": "",
  "duration_ms": 245
}
```

## Security Features

### Auto-Redacted Keywords
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

## Tips & Tricks

### Alias for Quick Logging
```bash
# Add to .bashrc or .zshrc
alias m='memlog exec'

# Usage
m "ls -la"
m "git status"
```

### View Recent Failures
```bash
memlog logs --failed --last 5
```

### Find Slow Commands
```bash
memlog logs --sort=duration --last 10
```

### Search for Errors
```bash
memlog logs --grep="error" --failed
```

### Daily Report
```bash
memlog logs --today | less
```

### Export Logs
```bash
# Copy today's logs
cat ~/.memlog/logs/memlog-$(date +%Y-%m-%d).jsonl > backup.jsonl
```

## Uninstall

### Linux/macOS
```bash
sudo rm /usr/local/bin/memlog
rm -rf ~/.memlog
# Remove hook from .bashrc/.zshrc
```

### Windows
```powershell
Remove-Item "$env:LOCALAPPDATA\memlog" -Recurse
# Remove from PATH in Environment Variables
# Remove hook from PowerShell profile
```

## Common Issues

### Command Not Found
```bash
# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc

# Or restart your terminal
```

### Logs Not Appearing
```bash
# Check log directory
ls -la ~/.memlog/logs/

# Run with explicit exec
memlog exec "echo test"
memlog logs --last 1
```

### Permission Denied
```bash
# Linux/macOS
chmod +x /usr/local/bin/memlog

# Check log directory permissions
chmod 755 ~/.memlog
chmod 755 ~/.memlog/logs
```

## More Information

- **Full Documentation**: [README.md](README.md)
- **Setup Guide**: [SETUP.md](SETUP.md)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)
- **GitHub**: [https://github.com/RuturajS/memlog](https://github.com/RuturajS/memlog)
