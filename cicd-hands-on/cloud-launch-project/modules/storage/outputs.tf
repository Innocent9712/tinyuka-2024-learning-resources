output "public_bucket_name" {
  description = "Name of the public S3 bucket"
  value       = aws_s3_bucket.public.id
}

output "public_bucket_arn" {
  description = "ARN of the public S3 bucket"
  value       = aws_s3_bucket.public.arn
}

output "private_bucket_name" {
  description = "Name of the private S3 bucket"
  value       = aws_s3_bucket.private.id
}

output "private_bucket_arn" {
  description = "ARN of the private S3 bucket"
  value       = aws_s3_bucket.private.arn
}

output "visible_bucket_name" {
  description = "Name of the visible S3 bucket"
  value       = aws_s3_bucket.visible.id
}

output "visible_bucket_arn" {
  description = "ARN of the visible S3 bucket"
  value       = aws_s3_bucket.visible.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.public.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.public.domain_name
}
