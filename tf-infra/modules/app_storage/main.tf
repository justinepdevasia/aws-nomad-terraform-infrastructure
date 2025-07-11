resource "aws_s3_bucket" "app_web_bucket" {
  bucket = "${var.app_web_bucket}"
}

resource "aws_s3_bucket" "app_media_bucket" {
  bucket = "${var.app_media_bucket}"
}

data "aws_iam_policy_document" "cloudfront_only_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${var.app_web_bucket}/${var.django_static_public_prefix}/*",
      "arn:aws:s3:::${var.app_web_bucket}/${var.django_media_public_prefix}/*",
      "arn:aws:s3:::${var.app_web_bucket}/${var.elixir_static_public_prefix}/*",
      "arn:aws:s3:::${var.app_web_bucket}/${var.elixir_media_public_prefix}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    
  }
}

resource "aws_s3_bucket_policy" "public_prefix" {
  bucket = "${var.app_web_bucket}"
  policy = "${data.aws_iam_policy_document.cloudfront_only_policy.json}"

  depends_on = [
    aws_s3_bucket.app_web_bucket
  ]
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for ${var.app_web_bucket}"
}

resource "aws_cloudfront_distribution" "app_web_cloudfront" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Example CloudFront distribution"

  origin {
    domain_name = "${var.app_web_bucket}.s3.${var.region}.amazonaws.com"
    origin_id   = "${var.app_web_bucket}.s3.${var.region}.amazonaws.com"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    target_origin_id = "${var.app_web_bucket}.s3.${var.region}.amazonaws.com"

    forwarded_values {
      cookies {
        forward = "all"
      }
      query_string = false
    }

    allowed_methods = ["GET", "HEAD"]

    cached_methods = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"

    min_ttl = 0

    default_ttl = 3600

    max_ttl = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [
    aws_s3_bucket.app_web_bucket
  ]
}