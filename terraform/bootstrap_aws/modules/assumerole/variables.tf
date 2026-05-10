variable "Region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "SharedAccountARN" {
  description = "ARN of the role of the where the bootstrap will be executed"
  type        = string
  default     = "default-prefix"
}

variable "TargetAccount" {
  description = "AWS account ID of the where Terraform infrastructure will be deployed"
  type        = string
  default     = "default-prefix"
}
variable "Prefix" {
  description = "A prefix to use for naming resources."
  type        = string
  default     = "default-prefix"
}

variable "Environment" {
  description = "The environment to deploy resources in."
  type        = string
}