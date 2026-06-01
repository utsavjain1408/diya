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

variable "subdomain_delegations" {
  description = "Map of child subdomain FQDN to its NS records. Used by the production run only to create delegation NS records in the parent zone. Populate from the dev/staging child zones' job-summary outputs."
  type        = map(list(string))
  default     = {}
}

variable "site_environments" {
  description = "Environments (EnvTag values) for which to build the static coming-soon site (S3 + CloudFront + ACM + Route 53)."
  type        = list(string)
  default     = ["Development"]
}