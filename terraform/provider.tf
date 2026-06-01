terraform {
  # Partial configuration; bucket/key/region are supplied at init time via
  # -backend-config flags in the GitHub Actions workflow.
  backend "s3" {}
}

provider "aws" {
  alias   = "primary"
  profile = "default"
  region  = var.Region
}

# us-east-1 provider for the CloudFront ACM certificate (CloudFront only reads
# certs from us-east-1). Uses the ambient credentials (OIDC in CI), not a profile.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias   = "development"
  profile = "<FILLMEIN>"
  region  = var.Region

  default_tags {
    tags = {
      Environment = "Development"
      Provisioner = "Terraform"
      Solution    = "AWS-GHA-TF-MSFT"
    }
  }
}

provider "aws" {
  alias   = "testing"
  profile = "<FILLMEIN>"
  region  = var.Region

  default_tags {
    tags = {
      Environment = "Testing"
      Provisioner = "Terraform"
      Solution    = "AWS-GHA-TF-MSFT"
    }
  }
}

provider "aws" {
  alias   = "production"
  profile = "<FILLMEIN>"
  region  = var.Region

  default_tags {
    tags = {
      Environment = "Production"
      Provisioner = "Terraform"
      Solution    = "AWS-GHA-TF-MSFT"
    }
  }
}