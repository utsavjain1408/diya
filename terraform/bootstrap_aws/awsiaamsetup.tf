data "aws_caller_identity" "shared" {
    provider = aws.Shared
}

data "aws_caller_identity" "development" {
    provider = aws.Development
}

data "aws_caller_identity" "staging" {
    provider = aws.Staging
}

data "aws_caller_identity" "production" {
    provider = aws.Production
}

module "assumerole_development" {
    source = "./modules/assumerole"
    providers = {
        aws = aws.Development
    }
    Region = var.Region
    Prefix = var.Prefix
    Environment = "Development"
    SharedAccountARN = data.aws_caller_identity.shared.arn
    TargetAccount = data.aws_caller_identity.development.account_id
}

module "assumerole_staging" {
    source = "./modules/assumerole"
    providers = {
        aws = aws.Staging
    }
    Region = var.Region
    Prefix = var.Prefix
    Environment = "Staging"
    SharedAccountARN = data.aws_caller_identity.shared.arn
    TargetAccount = data.aws_caller_identity.staging.account_id
}

module "assumerole_production" {
    source = "./modules/assumerole"
    providers = {
        aws = aws.Production
    }
    Region = var.Region
    Prefix = var.Prefix
    Environment = "Production"
    SharedAccountARN = data.aws_caller_identity.shared.arn
    TargetAccount = data.aws_caller_identity.production.account_id
}

output "role_arn" {
  value = {
    dev_role_arn  = module.assumerole_development.role_arn
    test_role_arn = module.assumerole_staging.role_arn
    prod_role_arn = module.assumerole_production.role_arn
  }
}