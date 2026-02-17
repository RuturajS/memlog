package logger

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

// LogEntry represents a single command execution log
type LogEntry struct {
	ID         int64  `json:"id"`
	Timestamp  string `json:"timestamp"`
	User       string `json:"user"`
	Host       string `json:"host"`
	Cwd        string `json:"cwd"`
	Command    string `json:"command"`
	ExitCode   int    `json:"exit_code"`
	Stdout     string `json:"stdout"`
	Stderr     string `json:"stderr"`
	DurationMs int64  `json:"duration_ms"`
}

// Logger handles async log writing
type Logger struct {
	logDir     string
	logChan    chan *LogEntry
	wg         sync.WaitGroup
	mu         sync.Mutex
	currentID  int64
	idFilePath string
}

var (
	instance *Logger
	once     sync.Once
)

// GetLogger returns singleton logger instance
func GetLogger() *Logger {
	once.Do(func() {
		homeDir, _ := os.UserHomeDir()
		logDir := filepath.Join(homeDir, ".memlog", "logs")
		os.MkdirAll(logDir, 0755)

		idFilePath := filepath.Join(homeDir, ".memlog", "counter.txt")
		
		instance = &Logger{
			logDir:     logDir,
			logChan:    make(chan *LogEntry, 100),
			idFilePath: idFilePath,
		}
		
		instance.loadCurrentID()
		instance.start()
	})
	return instance
}

// loadCurrentID loads the last used ID from disk
func (l *Logger) loadCurrentID() {
	data, err := os.ReadFile(l.idFilePath)
	if err == nil {
		fmt.Sscanf(string(data), "%d", &l.currentID)
	}
}

// saveCurrentID saves the current ID to disk
func (l *Logger) saveCurrentID() {
	os.WriteFile(l.idFilePath, []byte(fmt.Sprintf("%d", l.currentID)), 0644)
}

// getNextID returns the next incremental ID
func (l *Logger) getNextID() int64 {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.currentID++
	l.saveCurrentID()
	return l.currentID
}

// start begins the async log writer
func (l *Logger) start() {
	l.wg.Add(1)
	go func() {
		defer l.wg.Done()
		for entry := range l.logChan {
			l.writeLog(entry)
		}
	}()
}

// Log queues a log entry for async writing
func (l *Logger) Log(entry *LogEntry) {
	// Security: Don't log sensitive commands
	if l.isSensitive(entry.Command) {
		entry.Command = "[REDACTED - contains sensitive keywords]"
		entry.Stdout = "[REDACTED]"
		entry.Stderr = "[REDACTED]"
	}
	
	entry.ID = l.getNextID()
	entry.Timestamp = time.Now().Format(time.RFC3339)
	
	l.logChan <- entry
}

// isSensitive checks if command contains sensitive keywords
func (l *Logger) isSensitive(cmd string) bool {
	sensitive := []string{"password", "secret", "token", "api_key", "apikey"}
	cmdLower := strings.ToLower(cmd)
	for _, keyword := range sensitive {
		if strings.Contains(cmdLower, keyword) {
			return true
		}
	}
	return false
}

// writeLog writes a log entry to the appropriate file
func (l *Logger) writeLog(entry *LogEntry) error {
	filename := fmt.Sprintf("memlog-%s.jsonl", time.Now().Format("2006-01-02"))
	logPath := filepath.Join(l.logDir, filename)
	
	file, err := os.OpenFile(logPath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	defer file.Close()
	
	writer := bufio.NewWriter(file)
	encoder := json.NewEncoder(writer)
	
	if err := encoder.Encode(entry); err != nil {
		return err
	}
	
	return writer.Flush()
}

// Close gracefully shuts down the logger
func (l *Logger) Close() {
	close(l.logChan)
	l.wg.Wait()
}

// GetLogDir returns the log directory path
func (l *Logger) GetLogDir() string {
	return l.logDir
}
