output "parent_zone_id" {
  description = "Route 53 hosted zone ID for the parent domain (production only)."
  value       = local.is_production ? aws_route53_zone.parent[0].zone_id : null
}

output "parent_name_servers" {
  description = "NS records to configure for 'diya' under utsavjain.com at Squarespace (production only)."
  value       = local.is_production ? aws_route53_zone.parent[0].name_servers : null
}
