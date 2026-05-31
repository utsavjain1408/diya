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