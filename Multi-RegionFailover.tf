resource "aws_route53_record" "failover_record" {
  zone_id = aws_route53_zone.main.zone_id

  name = "failover.example.com"
  type = "A"

  failover_routing_policy {
    type = "PRIMARY"
    set_identifier = "primary"
    health_check_id = aws_route53_health_check.primary.id
  }

  records = [aws_s3_bucket.primary_bucket.website_endpoint]
  ttl     = 60
}

resource "aws_route53_health_check" "primary" {
  type = "HTTPS"
  resource_path = "/health-check"
  fqdn          = "primary.example.com"
}

resource "aws_s3_bucket" "primary_bucket" {
  bucket_prefix = "primary-bucket"
}

resource "aws_s3_bucket" "secondary_bucket" {
  bucket_prefix = "secondary-bucket"
  replication_configuration {
    role = aws_iam_role.replication_role.arn
    rules {
      status = "Enabled"
      destination {
        bucket = aws_s3_bucket.secondary_bucket.arn
      }
    }
  }
}
