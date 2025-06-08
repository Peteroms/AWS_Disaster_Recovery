# This Terraform configuration sets up a CloudFront distribution with two S3 origins
resource "aws_cloudfront_distribution" "mini_lab" {
  enabled             = true
  comment             = "CloudFront distribution for mini-lab failover setup"
  default_root_object = "index.html"

  origin {
    domain_name = "${var.account_id}-mini-lab-cf-virginia.s3.amazonaws.com"
    origin_id   = "mini-lab-origin-virginia"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }

    connection_attempts = 1
    connection_timeout  = 2
  }

  origin {
    domain_name = "${var.account_id}-mini-lab-cf-california.s3.us-west-1.amazonaws.com"
    origin_id   = "mini-lab-origin-california"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }

    connection_attempts = 1
    connection_timeout  = 2
  }

  origin_group {
    origin_id = "mini-lab-origin-group-example"

    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "mini-lab-origin-virginia"
    }

    member {
      origin_id = "mini-lab-origin-california"
    }
  }

  default_cache_behavior {
    target_origin_id       = "mini-lab-origin-group-example"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    aws_cloudfront_origin_access_identity.oai
  ]
}
