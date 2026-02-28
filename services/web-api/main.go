package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

type Item struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type StructuredLog struct {
	Severity       string      `json:"severity"`
	Message        string      `json:"message"`
	ServiceContext interface{} `json:"service_context"`
}

func main() {
	dbURL := os.Getenv("DATABASE_URL")
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to connect to DB: %v", err)
	}
	defer db.Close()

	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())

	r.GET("/items", func(c *gin.Context) {
		logEvent("INFO", "Fetching items from database")
		rows, err := db.Query("SELECT id, name FROM items")
		if err != nil {
			logEvent("ERROR", fmt.Sprintf("Failed to query database: %v", err))
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		defer rows.Close()

		items := []Item{}
		for rows.Next() {
			var item Item
			if err := rows.Scan(&item.ID, &item.Name); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}
			items = append(items, item)
		}

		c.JSON(http.StatusOK, items)
	})

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Println("\n🚀 Enterprise Serverless Platform is Starting...")
	fmt.Printf("🌍 Local URL:     http://localhost:%s\n", port)
	fmt.Printf("🏥 Health Check:   http://localhost:%s/health\n", port)
	fmt.Printf("📦 API Items:      http://localhost:%s/items\n\n", port)

	r.Run(":" + port)
}

func logEvent(severity, message string) {
	logObj := StructuredLog{
		Severity:       severity,
		Message:        message,
		ServiceContext: map[string]string{"service": "web-api"},
	}
	jsonLog, _ := json.Marshal(logObj)
	fmt.Println(string(jsonLog))
}
