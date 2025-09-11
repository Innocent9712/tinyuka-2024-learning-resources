# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Public S3 Bucket (for static website)
resource "aws_s3_bucket" "public" {
  bucket = "${var.project_name}-${var.environment}-public-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-bucket"
    Type        = "Public"
    Environment = var.environment
  }
}

# Public bucket policy - initially blocked, CloudFront will access it
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.public.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Website configuration for public bucket
resource "aws_s3_bucket_website_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Versioning for public bucket
resource "aws_s3_bucket_versioning" "public" {
  bucket = aws_s3_bucket.public.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Sample HTML file for public bucket
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.public.id
  key          = "index.html"
  content      = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${var.project_name} - Public Site</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .info { background: #e8f4f8; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to ${var.project_name}</h1>
        <p>This is a static website served from S3 via CloudFront.</p>
        <div class="info">
            <h3>Infrastructure Details:</h3>
            <ul>
                <li>VPC with public and private subnets</li>
                <li>Security groups for app and database tiers</li>
                <li>S3 buckets with proper access controls</li>
                <li>CloudFront distribution for content delivery</li>
                <li>IAM policies and groups for access management</li>
            </ul>
        </div>
        <p><em>Deployed with Terraform on AWS</em></p>
    </div>
</body>
</html>
EOF
  content_type = "text/html"

  tags = {
    Name = "index.html"
  }
}

# Origin Access Control for CloudFront
resource "aws_cloudfront_origin_access_control" "public" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "OAC for public S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "public" {
  origin {
    domain_name              = aws_s3_bucket.public.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.public.id
    origin_id                = "S3-${aws_s3_bucket.public.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.public.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudfront"
    Environment = var.environment
  }
}

# Bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.public.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.public.arn
          }
        }
      }
    ]
  })
}

# Private S3 Bucket
resource "aws_s3_bucket" "private" {
  bucket = "${var.project_name}-${var.environment}-private-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-bucket"
    Type        = "Private"
    Environment = var.environment
  }
}

# Private bucket - block all public access
resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning for private bucket
resource "aws_s3_bucket_versioning" "private" {
  bucket = aws_s3_bucket.private.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption for private bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
  bucket = aws_s3_bucket.private.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Visible S3 Bucket (restricted access)
resource "aws_s3_bucket" "visible" {
  bucket = "${var.project_name}-${var.environment}-visible-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-visible-bucket"
    Type        = "Visible"
    Environment = var.environment
  }
}

# Visible bucket - block all public access
resource "aws_s3_bucket_public_access_block" "visible" {
  bucket = aws_s3_bucket.visible.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning for visible bucket
resource "aws_s3_bucket_versioning" "visible" {
  bucket = aws_s3_bucket.visible.id
  versioning_configuration {
    status = "Enabled"
  }
}
