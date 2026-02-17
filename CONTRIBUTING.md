# Contributing to Memlog

Thank you for your interest in contributing to Memlog! This document provides guidelines and instructions for contributing.

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- **Clear title** describing the bug
- **Steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **Environment details** (OS, Go version, Memlog version)
- **Logs or screenshots** if applicable

### Suggesting Features

Feature requests are welcome! Please:
- Check if the feature has already been requested
- Clearly describe the feature and its use case
- Explain why this feature would be useful to most users

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/memlog.git
   cd memlog
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Write clean, readable code
   - Follow Go best practices
   - Add comments for complex logic
   - Update documentation if needed

4. **Test your changes**
   ```bash
   go test ./...
   go build ./cmd/memlog
   ```

5. **Format your code**
   ```bash
   go fmt ./...
   ```

6. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add amazing feature"
   ```
   
   Commit message format:
   - Use present tense ("Add feature" not "Added feature")
   - Use imperative mood ("Move cursor to..." not "Moves cursor to...")
   - Limit first line to 72 characters
   - Reference issues and pull requests

7. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

8. **Create a Pull Request**
   - Provide a clear description of the changes
   - Link related issues
   - Add screenshots for UI changes

## 📝 Code Style

### Go Style Guide

- Follow [Effective Go](https://go.dev/doc/effective_go)
- Use `gofmt` for formatting
- Use meaningful variable and function names
- Keep functions small and focused
- Add comments for exported functions

### Example

```go
// ExecuteCommand runs a shell command and logs the result.
// It returns the exit code and any error encountered.
func ExecuteCommand(cmd string) (int, error) {
    // Implementation
}
```

## 🧪 Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Aim for good test coverage

```bash
# Run tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run specific package tests
go test ./internal/logger
```

## 📚 Documentation

- Update README.md for user-facing changes
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)
- Add code comments for complex logic
- Update SETUP.md for development changes

## 🏗️ Project Structure

```
memlog/
├── cmd/memlog/          # CLI entry point
├── internal/            # Internal packages
│   ├── logger/          # Logging engine
│   ├── executor/        # Command execution
│   ├── storage/         # Log storage & retrieval
│   ├── cleanup/         # Log rotation & cleanup
│   └── report/          # Report generation
├── scripts/             # Installation scripts
└── templates/           # HTML templates
```

## 🎯 Areas for Contribution

### High Priority
- [ ] Background daemon implementation
- [ ] Real-time monitoring dashboard
- [ ] Performance optimizations
- [ ] Additional export formats (CSV, JSON)

### Medium Priority
- [ ] Command autocomplete based on history
- [ ] Integration with logging platforms
- [ ] Enhanced filtering options
- [ ] Configuration file support

### Low Priority
- [ ] Machine learning for anomaly detection
- [ ] Browser extension for web command logging
- [ ] Mobile app for viewing logs

## ✅ Checklist Before Submitting PR

- [ ] Code follows the project's style guidelines
- [ ] Self-review of code completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated and passing
- [ ] No new warnings or errors
- [ ] CHANGELOG.md updated

## 🐛 Debugging Tips

### Enable Verbose Logging
```go
// Add debug prints
fmt.Printf("Debug: %+v\n", variable)
```

### Test Locally
```bash
# Build and test
go build -o memlog ./cmd/memlog
./memlog exec "echo test"
./memlog logs --last 5
```

### Check Logs
```bash
# View log files
cat ~/.memlog/logs/memlog-*.jsonl
```

## 📞 Getting Help

- **Issues**: [GitHub Issues](https://github.com/RuturajS/memlog/issues)
- **Discussions**: [GitHub Discussions](https://github.com/RuturajS/memlog/discussions)
- **Email**: Create an issue for questions

## 📜 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all.

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information

## 📄 License

By contributing to Memlog, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Memlog! 🎉**
