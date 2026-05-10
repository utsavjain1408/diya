variable "region" {
    description = "AWS Region to deploy resources"
    type        = string
}

variable "prefix" {
    description = "Prefix used by all resources"
    type        = string
}

variable "environment" {
    description = "Deployment environment (e.g., dev, staging, prod)"
    type        = string
}

variable "github_org" {
    description = "GitHub organization name"
    type        = string
}

variable "github_repo" {
    description = "GitHub repository name"
    type        = string
}

variable "github_environment" {
    description = "GitHub environment name (e.g., dev, staging, prod)"
    type        = string
}