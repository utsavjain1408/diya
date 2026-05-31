locals {
  is_production = var.EnvTag == "Production"

  # Subdomain label per environment for the child zone
  # (dev.diya.utsavjain.com, staging.diya.utsavjain.com). Production owns the
  # parent zone itself, so it has no child subdomain.
  subdomain_label = {
    Development = "dev"
    Staging     = "staging"
    Production  = ""
  }
  child_domain = "${lookup(local.subdomain_label, var.EnvTag, lower(var.EnvTag))}.${var.parent_domain}"
}

# Step 1: Parent hosted zone for diya.utsavjain.com, created only during the
# production environment's tf-deploy run (the parent zone lives in the prod account).
#
# utsavjain.com is managed externally (Squarespace); its NS records for "diya"
# delegate diya.utsavjain.com to this zone.
resource "aws_route53_zone" "parent" {
  count = local.is_production ? 1 : 0
  name  = var.parent_domain

  tags = {
    Name = var.parent_domain
  }
}

# Step 3a: Child subdomain hosted zone for the non-production environments,
# created in that environment's own account (dev.diya... in dev, staging.diya...
# in staging). Its name servers are surfaced in the job summary so they can be
# wired into subdomain_delegations for the production run.
resource "aws_route53_zone" "child" {
  count = local.is_production ? 0 : 1
  name  = local.child_domain

  tags = {
    Name = local.child_domain
  }
}

# Step 3b: Delegation NS records created in the parent (production) zone, one per
# child subdomain. The NS values come from subdomain_delegations, populated from
# the child zones' job-summary outputs.
resource "aws_route53_record" "delegation" {
  for_each = local.is_production ? var.subdomain_delegations : {}

  zone_id = aws_route53_zone.parent[0].zone_id
  name    = each.key
  type    = "NS"
  ttl     = 172800
  records = each.value
}
