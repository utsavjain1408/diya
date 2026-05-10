provider "aws" {
    alias = "Shared"
    region = var.Region
    profile = "Shared"
    default_tags {
        tags = {
            Environment = "Shared"
            Provisioner = "Terraform"
            application = "diya"
            gitRepo = "https://github.com/utsavjain1408/diya.git"
        }
    }
    
}

provider "aws" {
    alias = "Development"
    region = var.Region
    profile = "Development"
    default_tags {
        tags = {
            Environment = "Development"
            Provisioner = "Terraform"
            application = "diya"
            gitRepo = "https://github.com/utsavjain1408/diya.git"
        }
    }
}

provider "aws" {
    alias = "Staging"
    region = var.Region
    profile = "Staging"
    default_tags {
        tags = {
            Environment = "Staging"
            Provisioner = "Terraform"
            application = "diya"
            gitRepo = "https://github.com/utsavjain1408/diya.git"
        }
    }
}

provider "aws" {
    alias = "Production"
    region = var.Region
    profile = "Production"
    default_tags {
        tags = {
            Environment = "Production"
            Provisioner = "Terraform"
            application = "diya"
            gitRepo = "https://github.com/utsavjain1408/diya.git"
        }
    }
}
