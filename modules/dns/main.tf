data "aws_route53_zone" "zone" {
  name         = "repelapp.de."
  private_zone = false
}

locals {
  domain              = "repelapp.de"
  github_pages_domain = "repelapp.github.io"
  s3_origin_id        = "repelapp-apex"
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

resource "aws_route53_record" "github_verify" {
  zone_id = data.aws_route53_zone.zone.zone_id

  name = "_github-challenge-repelapp.${data.aws_route53_zone.zone.name}"
  type = "TXT"
  ttl  = "300"
  records = [
    "ca27ec189f",
  ]
}

