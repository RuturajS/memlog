# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-17

### Added
- Initial release of Memlog
- Cross-platform command logging (Linux, macOS, Windows)
- Async logging engine with <20MB memory footprint
- Auto-incrementing log entry IDs
- Comprehensive metadata capture (timestamp, user, host, cwd, exit code, output, duration)
- Security features: automatic redaction of sensitive keywords
- Powerful CLI filtering options:
  - Filter by user, command, date, exit code
  - Grep search through command and output
  - Sort by time, duration, or exit code
- `memlog exec` - Execute and log commands
- `memlog logs` - View and filter logged commands
- `memlog show` - View detailed log entry by ID
- `memlog stats` - Display command statistics
- `memlog clean` - Log rotation and cleanup
- `memlog report` - Generate beautiful HTML reports with charts
- Automatic log rotation and compression
- Installation scripts for Linux, macOS, and Windows
- GitHub Actions workflow for automated releases
- Comprehensive documentation

### Security
- Automatic redaction of commands containing: password, secret, token, api_key, apikey
- Prevention of recursive logging via MEMLOG_ACTIVE environment variable

## [Unreleased]

### Planned
- Background daemon mode for automatic cleanup
- Real-time command monitoring dashboard
- Export to CSV/JSON formats
- Integration with popular logging platforms
- Command autocomplete suggestions based on history
- Machine learning-based anomaly detection
