resource "aws_s3_bucket" "terraform_state" {
  bucket = format("%s%s%s%s", var.prefix, "sss", var.environment, "tfstate") # Must be globally unique

  # Prevent accidental deletion of the state bucket
  lifecycle {
    prevent_destroy = true
  }
}
# Enable versioning so you can recover old state files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Object Lock on the S3 bucket (must be set at bucket creation)
resource "aws_s3_bucket_object_lock_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  depends_on = [aws_s3_bucket_versioning.enabled]

  rule {
    default_retention {
      mode = "GOVERNANCE"  # Use "COMPLIANCE" for stricter protection
      days = 30            # Adjust retention period as needed
    }
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the state bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Policy to enforce TLS 1.2 on Amazon S3 buckets
data "aws_iam_policy_document" "S3tfstateTLS" {
  statement {
    sid    = "Allow HTTPS only"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3*"
    ]
    resources = [
      "${aws_s3_bucket.terraform_state.arn}",
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
  statement {
    sid    = "Allow TLS 1.2 and above"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3*"
    ]
    resources = [
      "${aws_s3_bucket.terraform_state.arn}",
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

# Apply policy to enforce TLS 1.2 on Amazon S3 buckets
resource "aws_s3_bucket_policy" "tfstate" {
  bucket   = aws_s3_bucket.terraform_state.id
  policy   = data.aws_iam_policy_document.S3tfstateTLS.json
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# IAM policy to allow assume role
data "aws_iam_policy_document" "ghaassumerole" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.github_actions.arn}"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:environment:${var.github_environment}"]
    }
  }
}

# IAM policy allowing Github to create and manage AWS resources
data "aws_iam_policy_document" "TerraformState" {
  # Terraform state Amazon S3 access
  statement {
    actions   = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.terraform_state.arn}",
      "${aws_s3_bucket.terraform_state.arn}/*"
      ]
  }
}

# Create OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions" {
  name               = format("%s%s%s%s", var.prefix, "iar", var.environment, "gha")
  assume_role_policy = data.aws_iam_policy_document.ghaassumerole.json

  tags = {
    Name  = format("%s%s%s%s", var.prefix, "iar", var.environment, "gha")
    rtype = "security"
  }
}

resource "aws_iam_role_policy" "terraform_state" {
  name   = format("%s%s%s%s", var.prefix, "iap", var.environment, "TerraformState")
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.TerraformState.json
}

resource "aws_iam_role_policy" "diya_app" {
  name   = format("%s%s%s%s", var.prefix, "iap", var.environment, "DiyaApp")
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.DiyaApp.json
}

# Outputs used to create GitHub resources
output "gha_iam_role" {
  value = aws_iam_role.github_actions.arn
}
output "tfstate_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}
