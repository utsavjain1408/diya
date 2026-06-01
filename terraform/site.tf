locals {
  site_enabled = contains(var.site_environments, var.EnvTag)

  # The site FQDN is the apex of this environment's zone: dev.diya.utsavjain.com
  # for non-prod (child zone), diya.utsavjain.com for prod (parent zone).
  site_fqdn    = local.is_production ? var.parent_domain : local.child_domain
  site_zone_id = local.is_production ? aws_route53_zone.parent[0].zone_id : aws_route53_zone.child[0].zone_id

  site_bucket_name = "diya-site-${lower(var.EnvTag)}-${data.aws_caller_identity.current.account_id}"
  site_origin_id   = "s3-${local.site_bucket_name}"

  # AWS-managed CachingOptimized policy (global ID; avoids cloudfront:ListCachePolicies).
  cloudfront_cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

# Private S3 bucket holding the static site content.
resource "aws_s3_bucket" "site" {
  count         = local.site_enabled ? 1 : 0
  bucket        = local.site_bucket_name
  force_destroy = true

  tags = {
    Name        = local.site_bucket_name
    Environment = var.EnvTag
    Provisioner = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  count                   = local.site_enabled ? 1 : 0
  bucket                  = aws_s3_bucket.site[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Origin Access Control so only CloudFront can read the bucket.
resource "aws_cloudfront_origin_access_control" "site" {
  count                             = local.site_enabled ? 1 : 0
  name                              = "${local.site_bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ACM certificate for the site FQDN. CloudFront requires the cert in us-east-1.
resource "aws_acm_certificate" "site" {
  count             = local.site_enabled ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = local.site_fqdn
  validation_method = "DNS"

  tags = {
    Name        = local.site_fqdn
    Environment = var.EnvTag
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation records for the certificate, created in this environment's zone.
resource "aws_route53_record" "cert_validation" {
  for_each = local.site_enabled ? {
    for dvo in aws_acm_certificate.site[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id         = local.site_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "site" {
  count                   = local.site_enabled ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.site[0].arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# CloudFront distribution fronting the private bucket over HTTPS.
resource "aws_cloudfront_distribution" "site" {
  count               = local.site_enabled ? 1 : 0
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [local.site_fqdn]
  price_class         = "PriceClass_100"
  comment             = "Coming-soon site for ${local.site_fqdn}"

  origin {
    domain_name              = aws_s3_bucket.site[0].bucket_regional_domain_name
    origin_id                = local.site_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.site[0].id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.site_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = local.cloudfront_cache_policy_id
  }

  # Serve index.html for not-found paths (single-page coming-soon).
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site[0].certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name        = local.site_fqdn
    Environment = var.EnvTag
  }
}

# Allow only this distribution to read objects from the bucket.
data "aws_iam_policy_document" "site_bucket" {
  count = local.site_enabled ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site[0].arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  count  = local.site_enabled ? 1 : 0
  bucket = aws_s3_bucket.site[0].id
  policy = data.aws_iam_policy_document.site_bucket[0].json
}

# ALIAS record pointing the site FQDN at the CloudFront distribution.
resource "aws_route53_record" "site" {
  count   = local.site_enabled ? 1 : 0
  zone_id = local.site_zone_id
  name    = local.site_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site[0].domain_name
    zone_id                = aws_cloudfront_distribution.site[0].hosted_zone_id
    evaluate_target_health = false
  }
}
