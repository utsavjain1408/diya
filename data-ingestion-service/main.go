// main.go
package main

import (
	"encoding/json"
	"log"
	"os"

	"github.com/rabbitmq/amqp091-go"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

// MessagePayload defines the expected JSON structure from RabbitMQ.
type MessagePayload struct {
	Data string `json:"data"`
}

func main() {
	// --- Database Connection ---
	dsn := os.Getenv("DATABASE_URL")
	log.Println("Attempting to connect to database...")
	if dsn == "" {
		// Fallback DSN for local development
		dsn = "root:example@tcp(mariadb:3306)/diya?charset=utf8mb4&parseTime=True&loc=Local"
	}
	log.Println("Using DSN:: %s", dsn)
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	log.Println("Database connection successful.")

	// Automatically migrate the Record schema
	db.AutoMigrate(&Record{})
	log.Println("Database migration complete.")

	// --- RabbitMQ Connection ---
	rabbitMQURL := os.Getenv("RABBITMQ_URL")
	if rabbitMQURL == "" {
		rabbitMQURL = "amqp://guest:guest@rabbitmq:5672/"
	}

	conn, err := amqp091.Dial(rabbitMQURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		log.Fatalf("Failed to open a channel: %v", err)
	}
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"ingestion_queue", // name
		true,              // durable
		false,             // delete when unused
		false,             // exclusive
		false,             // no-wait
		nil,               // arguments
	)
	if err != nil {
		log.Fatalf("Failed to declare a queue: %v", err)
	}
	log.Println("Declared RabbitMQ queue:", q.Name)

	// Start consuming messages from the queue
	msgs, err := ch.Consume(
		q.Name, // queue
		"",     // consumer
		true,   // auto-ack (acknowledges message upon receipt)
		false,  // exclusive
		false,  // no-local
		false,  // no-wait
		nil,    // args
	)
	if err != nil {
		log.Fatalf("Failed to register a consumer: %v", err)
	}

	var forever chan struct{}

	go func() {
		for d := range msgs {
			log.Printf("Received a message: %s", d.Body)

			var payload MessagePayload
			if err := json.Unmarshal(d.Body, &payload); err != nil {
				log.Printf("Error decoding JSON: %s", err)
				continue
			}

			// Create a new record and save it to the database
			record := Record{Data: payload.Data}
			result := db.Create(&record)
			if result.Error != nil {
				log.Printf("Failed to save record: %v", result.Error)
			} else {
				log.Printf("Successfully saved record with ID: %d", record.ID)
			}
		}
	}()

	log.Println(" [*] Waiting for messages. To exit press CTRL+C")
	<-forever
}
