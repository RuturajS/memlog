package storage

import (
	"bufio"
	"compress/gzip"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/RuturajS/memlog/internal/logger"
)

// Storage handles reading and querying logs
type Storage struct {
	logDir string
}

// NewStorage creates a new storage instance
func NewStorage() *Storage {
	return &Storage{
		logDir: logger.GetLogger().GetLogDir(),
	}
}

// ReadLogs reads all logs matching the filter
func (s *Storage) ReadLogs(filter *Filter) ([]*logger.LogEntry, error) {
	var entries []*logger.LogEntry
	
	files, err := s.getLogFiles()
	if err != nil {
		return nil, err
	}
	
	for _, file := range files {
		fileEntries, err := s.readLogFile(file)
		if err != nil {
			continue
		}
		entries = append(entries, fileEntries...)
	}
	
	// Apply filters
	entries = s.applyFilters(entries, filter)
	
	// Sort
	s.sortEntries(entries, filter.SortBy)
	
	// Limit
	if filter.Limit > 0 && len(entries) > filter.Limit {
		entries = entries[:filter.Limit]
	}
	
	return entries, nil
}

// GetLogByID retrieves a specific log entry by ID
func (s *Storage) GetLogByID(id int64) (*logger.LogEntry, error) {
	files, err := s.getLogFiles()
	if err != nil {
		return nil, err
	}
	
	for _, file := range files {
		entries, err := s.readLogFile(file)
		if err != nil {
			continue
		}
		
		for _, entry := range entries {
			if entry.ID == id {
				return entry, nil
			}
		}
	}
	
	return nil, fmt.Errorf("log entry with ID %d not found", id)
}

// getLogFiles returns all log files sorted by date
func (s *Storage) getLogFiles() ([]string, error) {
	var files []string
	
	err := filepath.Walk(s.logDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		if !info.IsDir() && (strings.HasSuffix(path, ".jsonl") || strings.HasSuffix(path, ".jsonl.gz")) {
			files = append(files, path)
		}
		
		return nil
	})
	
	if err != nil {
		return nil, err
	}
	
	sort.Strings(files)
	return files, nil
}

// readLogFile reads a single log file (handles both plain and gzipped)
func (s *Storage) readLogFile(path string) ([]*logger.LogEntry, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	
	var reader io.Reader = file
	
	// Handle gzipped files
	if strings.HasSuffix(path, ".gz") {
		gzReader, err := gzip.NewReader(file)
		if err != nil {
			return nil, err
		}
		defer gzReader.Close()
		reader = gzReader
	}
	
	var entries []*logger.LogEntry
	scanner := bufio.NewScanner(reader)
	
	for scanner.Scan() {
		var entry logger.LogEntry
		if err := json.Unmarshal(scanner.Bytes(), &entry); err != nil {
			continue
		}
		entries = append(entries, &entry)
	}
	
	return entries, scanner.Err()
}

// applyFilters applies all filters to entries
func (s *Storage) applyFilters(entries []*logger.LogEntry, filter *Filter) []*logger.LogEntry {
	var filtered []*logger.LogEntry
	
	for _, entry := range entries {
		if s.matchesFilter(entry, filter) {
			filtered = append(filtered, entry)
		}
	}
	
	return filtered
}

// matchesFilter checks if an entry matches the filter criteria
func (s *Storage) matchesFilter(entry *logger.LogEntry, filter *Filter) bool {
	// User filter
	if filter.User != "" && entry.User != filter.User {
		return false
	}
	
	// Failed only
	if filter.FailedOnly && entry.ExitCode == 0 {
		return false
	}
	
	// Command filter
	if filter.Command != "" && !strings.Contains(entry.Command, filter.Command) {
		return false
	}
	
	// Grep filter
	if filter.Grep != "" {
		grep := strings.ToLower(filter.Grep)
		if !strings.Contains(strings.ToLower(entry.Command), grep) &&
			!strings.Contains(strings.ToLower(entry.Stdout), grep) &&
			!strings.Contains(strings.ToLower(entry.Stderr), grep) {
			return false
		}
	}
	
	// Date filters
	if filter.Since != "" {
		sinceTime, err := time.Parse("2006-01-02", filter.Since)
		if err == nil {
			entryTime, _ := time.Parse(time.RFC3339, entry.Timestamp)
			if entryTime.Before(sinceTime) {
				return false
			}
		}
	}
	
	if filter.Until != "" {
		untilTime, err := time.Parse("2006-01-02", filter.Until)
		if err == nil {
			entryTime, _ := time.Parse(time.RFC3339, entry.Timestamp)
			if entryTime.After(untilTime) {
				return false
			}
		}
	}
	
	// Today filter
	if filter.Today {
		today := time.Now().Format("2006-01-02")
		entryDate := entry.Timestamp[:10]
		if entryDate != today {
			return false
		}
	}
	
	return true
}

// sortEntries sorts entries based on the sort field
func (s *Storage) sortEntries(entries []*logger.LogEntry, sortBy string) {
	switch sortBy {
	case "duration":
		sort.Slice(entries, func(i, j int) bool {
			return entries[i].DurationMs > entries[j].DurationMs
		})
	case "exit":
		sort.Slice(entries, func(i, j int) bool {
			return entries[i].ExitCode > entries[j].ExitCode
		})
	case "time":
		fallthrough
	default:
		sort.Slice(entries, func(i, j int) bool {
			return entries[i].Timestamp > entries[j].Timestamp
		})
	}
}

// Filter represents query filters
type Filter struct {
	User       string
	FailedOnly bool
	Command    string
	Grep       string
	Since      string
	Until      string
	Today      bool
	Limit      int
	SortBy     string
}
