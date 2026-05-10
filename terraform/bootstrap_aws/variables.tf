variable "Region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "Prefix" {
  description = "A prefix to use for naming resources."
  type        = string
  default     = "default-prefix"
}