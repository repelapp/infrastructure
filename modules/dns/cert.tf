resource "aws_acm_certificate" "cert" {
  domain_name = local.domain
  subject_alternative_names = [
    "*.${local.domain}",
  ]

  validation_method = "DNS"
}


resource "aws_route53_record" "cert_validation_wildcard" {
  name    = aws_acm_certificate.cert.domain_validation_options[1].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[1].resource_record_type
  zone_id = data.aws_route53_zone.zone.id
  records = [
    aws_acm_certificate.cert.domain_validation_options[1].resource_record_value,
  ]
  ttl = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    aws_route53_record.cert_validation_wildcard.fqdn,
  ]
}


provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cloudfront" {
  provider    = aws.us-east-1
  domain_name = local.domain
  subject_alternative_names = [
    "*.${local.domain}",
  ]

  validation_method = "DNS"
}

# The same validation holds globally
