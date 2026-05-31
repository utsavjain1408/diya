### Create GitHub pipeline resources

# Create GitHub branch per environment. Existing Main branch is used for prod
resource "github_branch" "dev" {
  repository = var.github_repo
  branch     = "development"
}

resource "github_branch" "stage" {
  repository = var.github_repo
  branch     = "staging"
}

# Local variables used to define GitHub Environments and Secrets configuration
locals {
  gha_environment = ["development", "staging", "production"]

  gha_iam_role = {
    development = module.tfbootstrap_dev.gha_iam_role
    staging     = module.tfbootstrap_stage.gha_iam_role
    production  = module.tfbootstrap_prod.gha_iam_role
  }
  tfstate_bucket_name = {
    development = module.tfbootstrap_dev.tfstate_bucket_name
    staging     = module.tfbootstrap_stage.tfstate_bucket_name
    production  = module.tfbootstrap_prod.tfstate_bucket_name
  }
}

# Create GitHub Environments
resource "github_repository_environment" "env" {
  for_each = toset(local.gha_environment)

  environment = each.value
  repository  = var.github_repo

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

# Create GitHub environment branch policies
resource "github_repository_environment_deployment_policy" "development" {
  repository     = var.github_repo
  environment    = github_repository_environment.env["development"].environment
  branch_pattern = "development*"
}

resource "github_repository_environment_deployment_policy" "dev2staging" {
  repository     = var.github_repo
  environment    = github_repository_environment.env["staging"].environment
  branch_pattern = "development*"
}

resource "github_repository_environment_deployment_policy" "staging" {
  repository     = var.github_repo
  environment    = github_repository_environment.env["staging"].environment
  branch_pattern = "staging*"
}

resource "github_repository_environment_deployment_policy" "staging2prod" {
  repository     = var.github_repo
  environment    = github_repository_environment.env["production"].environment
  branch_pattern = "staging*"
}

resource "github_repository_environment_deployment_policy" "prod" {
  repository     = var.github_repo
  environment    = github_repository_environment.env["production"].environment
  branch_pattern = "main"
}

# Create GitHub branch protection policy
resource "github_branch_protection" "main" {
  repository_id          = var.github_repo
  pattern                = "main"
  require_signed_commits = true

  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
}

### Create GitHub Environment Secrets

# IAM Role ARN used by GitHub Actions runner to deploy AWS resources
resource "github_actions_environment_secret" "AWS_ROLE" {
  for_each = github_repository_environment.env

  repository      = var.github_repo
  environment     = each.value.environment
  secret_name     = "AWS_ROLE"
  plaintext_value = lookup(local.gha_iam_role, each.value.environment, null)
}

# Terraform state S3 bucket name
resource "github_actions_environment_secret" "TF_STATE_BUCKET_NAME" {
  for_each = github_repository_environment.env

  repository      = var.github_repo
  environment     = each.value.environment
  secret_name     = "TF_STATE_BUCKET_NAME"
  plaintext_value = lookup(local.tfstate_bucket_name, each.value.environment, null)
}

# Terraform state S3 bucket key
resource "github_actions_environment_secret" "TF_STATE_BUCKET_KEY" {
  for_each = github_repository_environment.env

  repository      = var.github_repo
  environment     = each.value.environment
  secret_name     = "TF_STATE_BUCKET_KEY"
  plaintext_value = "terraform/${each.value.environment}.tfstate"
}

# Infracost API Key
# resource "github_actions_environment_secret" "INFRACOST_API_KEY" {

#   repository      = var.github_repo
#   environment     = "test"
#   secret_name     = "INFRACOST_API_KEY"
#   plaintext_value = var.InfraCostAPIKey

#   depends_on = [github_repository_environment.env]
# }

### Create GitHub Environment Variables

# Locals used for constructing GitHub Variables
locals {
  # Declare GitHub Environments variables
  environment_variables_common = {
    # Deployment region e.g. eu-west-1
    TF_VAR_REGION     = "us-west-2"
    # Deployment Availability Zone 1 e.g. eu-west-1a
    TF_VAR_AZ01       = "us-west-2a"
    # Deployment Availability Zone 2 e.g. eu-west-1b
    TF_VAR_AZ02       = "us-west-2b"
    # The Public IP address from which the web application will be accessed e.g. x.x.x.x/32
    TF_VAR_PUBLICIP   = "<FILLMEIN>"
    # A prefix appended to the name of all AWS-created resources e.g. ghablog WARNING: use lowercase character only and no symbols
    TF_VAR_PREFIX     = "<FILLMEIN>"
    TF_VAR_SOLTAG     = "Diya"
    TF_VAR_GITHUBREPO = format("%s%s%s", var.github_repo, "/", var.github_repo)
    # The first two octets of the CIDR IP address range e.g. 10.0
    TF_VAR_VPCCIDR    = "<FILLMEIN>"
    TF_VAR_ECRREPO    = "na"
    TF_VAR_IMAGETAG   = "1.0.0"
  }
  # Declare dev specific GitHub Environments variables
  environment_variables_dev = merge(
    local.environment_variables_common,
    {
      TF_VAR_ENVCODE = "dev"
      TF_VAR_ENVTAG  = "Development"
    }
  )
  # Declare test specific GitHub Environments variables
  environment_variables_test = merge(
    local.environment_variables_common,
    {
      TF_VAR_ENVCODE = "stage"
      TF_VAR_ENVTAG  = "Staging"
    }
  )
  # Declare prod specific GitHub Environments variables
  environment_variables_prod = merge(
    local.environment_variables_common,
    {
      TF_VAR_ENVCODE = "prod"
      TF_VAR_ENVTAG  = "Production"
    }
  )
}

# Create GitHub Environment Variables
resource "github_actions_environment_variable" "dev" {
  for_each = local.environment_variables_dev

  repository    = var.github_repo
  environment   = github_repository_environment.env["development"].environment
  variable_name = each.key
  value         = each.value
}

resource "github_actions_environment_variable" "test" {
  for_each = local.environment_variables_test

  repository    = var.github_repo
  environment   = github_repository_environment.env["staging"].environment
  variable_name = each.key
  value         = each.value
}

resource "github_actions_environment_variable" "prod" {
  for_each = local.environment_variables_prod

  repository    = var.github_repo
  environment   = github_repository_environment.env["production"].environment
  variable_name = each.key
  value         = each.value
}