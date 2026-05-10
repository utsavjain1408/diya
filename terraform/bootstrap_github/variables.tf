variable region {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-west-2"
}
variable prefix {
    description = "Prefix used by all resources"
    type        = string
    default     = "diya"
}

variable develpment_role_arn {
  description = "ARN of the IAM role to assume for development environment"
  type        = string
}

variable staging_role_arn {
  description = "ARN of the IAM role to assume for staging environment"
  type        = string
}

variable production_role_arn {
  description = "ARN of the IAM role to assume for production environment"
  type        = string
}

variable github_org {
    description = "GitHub organization name"
    type        = string
}

variable github_repo {
    description = "GitHub repository name"
    type        = string
}