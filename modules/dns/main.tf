data "aws_route53_zone" "zone" {
  name         = "repelapp.de."
  private_zone = false
}

locals {
  domain              = "repelapp.de"
  github_pages_domain = "repelapp.github.io"
  s3_origin_id        = "repelapp-apex"
}

resource "aws_s3_bucket" "website-apex" {
  bucket = local.domain
  acl    = "public-read"

  website {
    redirect_all_requests_to = "https://www.${local.domain}"
  }
}

resource "aws_cloudfront_distribution" "website-apex" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.website-apex.website_domain
    origin_id   = local.s3_origin_id
  }

  aliases = [
    local.domain,
  ]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}

# repelapp.de
resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.zone.zone_id


  name = data.aws_route53_zone.zone.name
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.website-apex.domain_name
    zone_id                = aws_cloudfront_distribution.website-apex.hosted_zone_id
    evaluate_target_health = true
  }
}


# www.repelapp.de
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id

  name = "www.${data.aws_route53_zone.zone.name}"
  type = "CNAME"
  ttl  = "300"
  records = [
    local.github_pages_domain,
  ]
}

