variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
  default     = "diya-terraform-bucket"
}

variable "Region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-2"
}

variable "EnvTag" {
  description = "Environment name (Development, Staging, Production). Supplied per-environment by the workflow as TF_VAR_EnvTag."
  type        = string
  default     = "Development"
}

variable "parent_domain" {
  description = "Delegated parent subdomain whose hosted zone lives in the production account."
  type        = string
  default     = "diya.utsavjain.com"
}