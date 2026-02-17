package cleanup

import (
	"compress/gzip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/RuturajS/memlog/internal/logger"
)

// Cleanup handles log rotation and cleanup
type Cleanup struct {
	logDir string
}

// NewCleanup creates a new cleanup instance
func NewCleanup() *Cleanup {
	return &Cleanup{
		logDir: logger.GetLogger().GetLogDir(),
	}
}

// RotateIfNeeded rotates logs if they exceed the size limit
func (c *Cleanup) RotateIfNeeded(maxSizeMB int64) error {
	files, err := c.getLogFiles()
	if err != nil {
		return err
	}
	
	for _, file := range files {
		if strings.HasSuffix(file, ".gz") {
			continue
		}
		
		info, err := os.Stat(file)
		if err != nil {
			continue
		}
		
		sizeMB := info.Size() / (1024 * 1024)
		if sizeMB > maxSizeMB {
			if err := c.compressFile(file); err != nil {
				fmt.Printf("Failed to compress %s: %v\n", file, err)
			}
		}
	}
	
	return nil
}

// CleanOldLogs removes logs older than the specified days
func (c *Cleanup) CleanOldLogs(days int) error {
	files, err := c.getLogFiles()
	if err != nil {
		return err
	}
	
	cutoff := time.Now().AddDate(0, 0, -days)
	
	for _, file := range files {
		info, err := os.Stat(file)
		if err != nil {
			continue
		}
		
		if info.ModTime().Before(cutoff) {
			if err := os.Remove(file); err != nil {
				fmt.Printf("Failed to remove %s: %v\n", file, err)
			} else {
				fmt.Printf("Removed old log: %s\n", filepath.Base(file))
			}
		}
	}
	
	return nil
}

// CompressOldLogs compresses uncompressed logs older than 1 day
func (c *Cleanup) CompressOldLogs() error {
	files, err := c.getLogFiles()
	if err != nil {
		return err
	}
	
	yesterday := time.Now().AddDate(0, 0, -1)
	
	for _, file := range files {
		if strings.HasSuffix(file, ".gz") {
			continue
		}
		
		info, err := os.Stat(file)
		if err != nil {
			continue
		}
		
		if info.ModTime().Before(yesterday) {
			if err := c.compressFile(file); err != nil {
				fmt.Printf("Failed to compress %s: %v\n", file, err)
			}
		}
	}
	
	return nil
}

// compressFile compresses a log file to .gz
func (c *Cleanup) compressFile(path string) error {
	input, err := os.Open(path)
	if err != nil {
		return err
	}
	defer input.Close()
	
	outputPath := path + ".gz"
	output, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer output.Close()
	
	gzWriter := gzip.NewWriter(output)
	defer gzWriter.Close()
	
	if _, err := io.Copy(gzWriter, input); err != nil {
		os.Remove(outputPath)
		return err
	}
	
	// Remove original file after successful compression
	if err := os.Remove(path); err != nil {
		return err
	}
	
	fmt.Printf("Compressed: %s -> %s\n", filepath.Base(path), filepath.Base(outputPath))
	return nil
}

// getLogFiles returns all log files
func (c *Cleanup) getLogFiles() ([]string, error) {
	var files []string
	
	err := filepath.Walk(c.logDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		if !info.IsDir() && (strings.HasSuffix(path, ".jsonl") || strings.HasSuffix(path, ".jsonl.gz")) {
			files = append(files, path)
		}
		
		return nil
	})
	
	return files, err
}

// GetTotalSize returns total size of all logs in MB
func (c *Cleanup) GetTotalSize() (int64, error) {
	files, err := c.getLogFiles()
	if err != nil {
		return 0, err
	}
	
	var totalSize int64
	for _, file := range files {
		info, err := os.Stat(file)
		if err != nil {
			continue
		}
		totalSize += info.Size()
	}
	
	return totalSize / (1024 * 1024), nil
}
