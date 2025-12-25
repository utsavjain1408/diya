// main.go
package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var db *gorm.DB
var err error

func main() {
	// --- Database Connection ---
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "root:example@tcp(mariadb:3306)/diya?charset=utf8mb4&parseTime=True&loc=Local"
	}
	log.Println("Using Databsase source: %v", dsn)
	db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	log.Println("Database connection successful.")


	// --- API Server Setup ---
	router := gin.Default()

	// API Route for getting all records
	router.GET("/records", getRecords)

	log.Println("Starting server on port 8082")
	router.Run(":8082")
}

// getRecords handles the GET /records request.
func getRecords(c *gin.Context) {
	var records []Record

	// Find all records in the database
	result := db.Find(&records)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, records)
}
