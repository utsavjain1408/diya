output "parent_zone_id" {
  description = "Route 53 hosted zone ID for the parent domain (production only)."
  value       = local.is_production ? aws_route53_zone.parent[0].zone_id : null
}

output "parent_name_servers" {
  description = "NS records to configure for 'diya' under utsavjain.com at Squarespace (production only)."
  value       = local.is_production ? aws_route53_zone.parent[0].name_servers : null
}

output "child_zone_name" {
  description = "Child subdomain zone name (non-production only)."
  value       = local.is_production ? null : aws_route53_zone.child[0].name
}

output "child_name_servers" {
  description = "NS records for the child subdomain zone (non-production only). Add these to subdomain_delegations for the production run."
  value       = local.is_production ? null : aws_route53_zone.child[0].name_servers
}

output "site_bucket" {
  description = "S3 bucket name for the static site (set as the SITE_BUCKET environment variable for deploy-site)."
  value       = local.site_enabled ? aws_s3_bucket.site[0].bucket : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (set as CLOUDFRONT_DISTRIBUTION_ID to enable cache invalidation in deploy-site)."
  value       = local.site_enabled ? aws_cloudfront_distribution.site[0].id : null
}

output "site_url" {
  description = "Public URL for the static site."
  value       = local.site_enabled ? "https://${local.site_fqdn}" : null
}
