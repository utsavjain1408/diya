// model.go
package main

import "gorm.io/gorm"

// Record represents a data entry in the database.
type Record struct {
	gorm.Model
	Data string `json:"data"`
}