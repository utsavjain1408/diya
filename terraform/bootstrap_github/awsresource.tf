### Create AWS resources for Terraform bootstrapping across multiple accounts
module "tfbootstrap_dev" {
  source = "./modules/tfbootstrap"
  providers = {
    aws = aws.development
  }
  region             = var.region
  prefix             = var.prefix
  environment        = "development"
  github_org         = var.github_org
  github_repo        = var.github_repo
  github_environment = "development"
}

module "tfbootstrap_stage" {
  source = "./modules/tfbootstrap"
  providers = {
    aws = aws.testing
  }
  region             = var.region
  prefix             = var.prefix
  environment        = "staging"
  github_org         = var.github_org
  github_repo        = var.github_repo
  github_environment = "stageing"
}

module "tfbootstrap_prod" {
  source = "./modules/tfbootstrap"
  providers = {
    aws = aws.production
  }
  region             = var.region
  prefix             = var.prefix
  environment        = "production"
  github_org         = var.github_org
  github_repo        = var.github_repo
  github_environment = "production"
}