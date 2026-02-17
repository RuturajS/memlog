package executor

import (
	"bytes"
	"io"
	"os"
	"os/exec"
	"os/user"
	"runtime"
	"time"

	"github.com/RuturajS/memlog/internal/logger"
)

// Execute runs a command and logs the result
func Execute(cmdString string) (int, error) {
	start := time.Now()
	
	// Get system info
	currentUser, _ := user.Current()
	hostname, _ := os.Hostname()
	cwd, _ := os.Getwd()
	
	// Prepare command based on OS
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("powershell", "-Command", cmdString)
	} else {
		cmd = exec.Command("sh", "-c", cmdString)
	}
	
	// Capture output
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	
	// Execute
	err := cmd.Run()
	exitCode := 0
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			exitCode = exitErr.ExitCode()
		} else {
			exitCode = 1
		}
	}
	
	duration := time.Since(start).Milliseconds()
	
	// Log the execution
	entry := &logger.LogEntry{
		User:       currentUser.Username,
		Host:       hostname,
		Cwd:        cwd,
		Command:    cmdString,
		ExitCode:   exitCode,
		Stdout:     stdout.String(),
		Stderr:     stderr.String(),
		DurationMs: duration,
	}
	
	logger.GetLogger().Log(entry)
	
	return exitCode, err
}

// ExecuteInteractive runs a command interactively (prints output in real-time)
func ExecuteInteractive(cmdString string) int {
	start := time.Now()
	
	// Get system info
	currentUser, _ := user.Current()
	hostname, _ := os.Hostname()
	cwd, _ := os.Getwd()
	
	// Prepare command based on OS
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("powershell", "-Command", cmdString)
	} else {
		cmd = exec.Command("sh", "-c", cmdString)
	}
	
	// Capture AND display output
	// Also capture for logging
	stdoutCapture := &bytes.Buffer{}
	stderrCapture := &bytes.Buffer{}
	
	cmd.Stdout = io.MultiWriter(os.Stdout, stdoutCapture)
	cmd.Stderr = io.MultiWriter(os.Stderr, stderrCapture)
	
	// Execute
	err := cmd.Run()
	exitCode := 0
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			exitCode = exitErr.ExitCode()
		} else {
			exitCode = 1
		}
	}
	
	duration := time.Since(start).Milliseconds()
	
	// Log the execution
	entry := &logger.LogEntry{
		User:       currentUser.Username,
		Host:       hostname,
		Cwd:        cwd,
		Command:    cmdString,
		ExitCode:   exitCode,
		Stdout:     stdoutCapture.String(),
		Stderr:     stderrCapture.String(),
		DurationMs: duration,
	}
	
	logger.GetLogger().Log(entry)
	
	return exitCode
}
