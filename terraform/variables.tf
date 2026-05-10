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