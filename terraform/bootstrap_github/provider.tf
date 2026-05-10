terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0.0"
    }
  }
}

provider "github" {
  owner = "utsavjain1408"
}

provider "aws" {
  alias   = "development"
  profile = "default"
  region  = var.region

  assume_role {

    role_arn = var.develpment_role_arn
  }
  default_tags {
    tags = {
      Environment = "Development"
      Provisioner = "Terraform"
      Repo    = "github.com:utsavjain1408/diya.git"
    }
  }
}

provider "aws" {
  alias   = "staging"
  profile = "default"
  region  = var.region

  assume_role {
    role_arn = var.staging_role_arn
  }
  default_tags {
    tags = {
      Environment = "Staging"
      Provisioner = "Terraform"
      Repo    = "github.com:utsavjain1408/diya.git"
    }
  }
}

provider "aws" {
  alias   = "production"
  profile = "default"
  region  = var.region

  assume_role {
    role_arn = var.production_role_arn
  }

  default_tags {
    tags = {
      Environment = "Production"
      Provisioner = "Terraform"
      Repo    = "github.com:utsavjain1408/diya.git"
    }
  }
}