locals {
  is_production = var.EnvTag == "Production"
}

# Step 1: Parent hosted zone for diya.utsavjain.com, created only during the
# production environment's tf-deploy run (the parent zone lives in the prod account).
#
# utsavjain.com is managed externally (Squarespace). After this zone exists, its
# NS records (surfaced in the workflow job summary) must be added at Squarespace
# as an NS record set for "diya", delegating diya.utsavjain.com to this zone.
#
# Step 3 (dev/staging subdomain zones + their delegation NS records) is added
# once delegation is verified.
resource "aws_route53_zone" "parent" {
  count = local.is_production ? 1 : 0
  name  = var.parent_domain

  tags = {
    Name = var.parent_domain
  }
}
