data "aws_caller_identity" "current" {}

# Bucket name is suffixed with the environment and account ID so the same root
# config can be applied to all environments (and accounts) without S3's global
# name collisions.
resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_name}-${lower(var.EnvTag)}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags = {
    Environment = var.EnvTag
    Provisioner = "Terraform"
  }
}
