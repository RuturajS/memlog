package report

import (
	"fmt"
	"html/template"
	"os"
	"sort"
	"strings"
	"time"

	"github.com/RuturajS/memlog/internal/logger"
	"github.com/RuturajS/memlog/internal/storage"
)

// ReportData holds data for HTML report generation
type ReportData struct {
	FromDate          string
	ToDate            string
	TotalCommands     int
	FailedCommands    int
	SuccessRate       float64
	MostUsedCommands  []CommandStat
	ActivityByHour    []HourStat
	TopDirectories    []DirStat
	LongestCommands   []*logger.LogEntry
	GeneratedAt       string
}

type CommandStat struct {
	Command string
	Count   int
}

type HourStat struct {
	Hour  int
	Count int
}

type DirStat struct {
	Directory string
	Count     int
}

// Generator handles report generation
type Generator struct {
	storage      *storage.Storage
	templatePath string
}

// NewGenerator creates a new report generator
func NewGenerator(templatePath string) *Generator {
	return &Generator{
		storage:      storage.NewStorage(),
		templatePath: templatePath,
	}
}

// Generate creates an HTML report
func (g *Generator) Generate(from, to string, outputPath string) error {
	// Read logs
	filter := &storage.Filter{
		Since: from,
		Until: to,
	}
	
	entries, err := g.storage.ReadLogs(filter)
	if err != nil {
		return err
	}
	
	// Build report data
	data := g.buildReportData(entries, from, to)
	
	// Load template
	tmpl, err := template.ParseFiles(g.templatePath)
	if err != nil {
		return err
	}
	
	// Create output file
	file, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer file.Close()
	
	// Execute template
	return tmpl.Execute(file, data)
}

// buildReportData analyzes entries and builds report data
func (g *Generator) buildReportData(entries []*logger.LogEntry, from, to string) *ReportData {
	data := &ReportData{
		FromDate:    from,
		ToDate:      to,
		GeneratedAt: time.Now().Format("2006-01-02 15:04:05"),
	}
	
	if len(entries) == 0 {
		return data
	}
	
	data.TotalCommands = len(entries)
	
	// Count failures
	failedCount := 0
	for _, entry := range entries {
		if entry.ExitCode != 0 {
			failedCount++
		}
	}
	data.FailedCommands = failedCount
	data.SuccessRate = float64(data.TotalCommands-failedCount) / float64(data.TotalCommands) * 100
	
	// Most used commands
	data.MostUsedCommands = g.getMostUsedCommands(entries)
	
	// Activity by hour
	data.ActivityByHour = g.getActivityByHour(entries)
	
	// Top directories
	data.TopDirectories = g.getTopDirectories(entries)
	
	// Longest running commands
	data.LongestCommands = g.getLongestCommands(entries)
	
	return data
}

// getMostUsedCommands returns top 10 most used commands
func (g *Generator) getMostUsedCommands(entries []*logger.LogEntry) []CommandStat {
	cmdCount := make(map[string]int)
	
	for _, entry := range entries {
		// Extract base command (first word)
		parts := strings.Fields(entry.Command)
		if len(parts) > 0 {
			cmd := parts[0]
			cmdCount[cmd]++
		}
	}
	
	var stats []CommandStat
	for cmd, count := range cmdCount {
		stats = append(stats, CommandStat{Command: cmd, Count: count})
	}
	
	sort.Slice(stats, func(i, j int) bool {
		return stats[i].Count > stats[j].Count
	})
	
	if len(stats) > 10 {
		stats = stats[:10]
	}
	
	return stats
}

// getActivityByHour returns command count by hour
func (g *Generator) getActivityByHour(entries []*logger.LogEntry) []HourStat {
	hourCount := make(map[int]int)
	
	for _, entry := range entries {
		t, err := time.Parse(time.RFC3339, entry.Timestamp)
		if err == nil {
			hourCount[t.Hour()]++
		}
	}
	
	var stats []HourStat
	for hour := 0; hour < 24; hour++ {
		stats = append(stats, HourStat{Hour: hour, Count: hourCount[hour]})
	}
	
	return stats
}

// getTopDirectories returns top 10 most used directories
func (g *Generator) getTopDirectories(entries []*logger.LogEntry) []DirStat {
	dirCount := make(map[string]int)
	
	for _, entry := range entries {
		dirCount[entry.Cwd]++
	}
	
	var stats []DirStat
	for dir, count := range dirCount {
		stats = append(stats, DirStat{Directory: dir, Count: count})
	}
	
	sort.Slice(stats, func(i, j int) bool {
		return stats[i].Count > stats[j].Count
	})
	
	if len(stats) > 10 {
		stats = stats[:10]
	}
	
	return stats
}

// getLongestCommands returns top 10 longest running commands
func (g *Generator) getLongestCommands(entries []*logger.LogEntry) []*logger.LogEntry {
	sorted := make([]*logger.LogEntry, len(entries))
	copy(sorted, entries)
	
	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].DurationMs > sorted[j].DurationMs
	})
	
	if len(sorted) > 10 {
		sorted = sorted[:10]
	}
	
	return sorted
}
