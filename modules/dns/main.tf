data "aws_route53_zone" "zone" {
  name         = "repelapp.de."
  private_zone = false
}

locals {
  github_pages_domain = "repelapp.github.io"

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

