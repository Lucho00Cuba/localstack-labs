# CloudFront

resource "aws_s3_bucket" "website_bucket" {
  bucket = local.website_bucket
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website_bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "website_file_index" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "index.html"
  source       = "${path.root}/www/index.html"
  etag         = filemd5("${path.root}/www/index.html")
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_object" "website_file_js" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "app.js"
  source       = "${path.root}/www/app.js"
  etag         = filemd5("${path.root}/www/app.js")
  content_type = "application/javascript"
  acl          = "public-read"
}

resource "aws_s3_object" "website_file_icon" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "favicon.ico"
  source       = "${path.root}/www/favicon.ico"
  etag         = filemd5("${path.root}/www/favicon.ico")
  content_type = "image/x-icon"
  acl          = "public-read"
}

resource "aws_cloudfront_origin_access_identity" "cdn_identity" {
  comment = "OAI for CloudFront to access S3 bucket"
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.bucket
  policy = templatefile("policies/website_s3_bucket.json.tpl", {
    cdn_identity_arn   = aws_cloudfront_origin_access_identity.cdn_identity.iam_arn
    website_bucket_arn = aws_s3_bucket.website_bucket.arn
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.website_bucket.bucket

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "website_block_public_access" {
  bucket = aws_s3_bucket.website_bucket.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
