output "app_users_group_name" {
  description = "The name of the IAM group for application users"
  value       = aws_iam_group.app_users_group.name
}

output "app_users_group_arn" {
  description = "The ARN of the IAM group for application users"
  value       = aws_iam_group.app_users_group.arn
}

output "vpc_s3_policy_arn" {
  description = "The ARN of the IAM policy for VPC and S3 access"
  value       = aws_iam_policy.vpc_s3_policy.arn
}
