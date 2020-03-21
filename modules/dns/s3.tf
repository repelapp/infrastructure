resource "aws_s3_bucket" "website-apex" {
  bucket = local.domain
  acl    = "public-read"

  website {
    redirect_all_requests_to = "https://www.${local.domain}"
  }
}
