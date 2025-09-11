output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = module.networking.vpc_arn
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "app_subnet_id" {
  description = "ID of the app private subnet"
  value       = module.networking.app_subnet_id
}

output "db_subnet_id" {
  description = "ID of the db private subnet"
  value       = module.networking.db_subnet_id
}

output "app_security_group_id" {
  description = "ID of the app security group"
  value       = module.security.app_security_group_id
}

output "db_security_group_id" {
  description = "ID of the db security group"
  value       = module.security.db_security_group_id
}

output "s3_buckets" {
  description = "S3 bucket information"
  value = {
    public_bucket_name  = module.storage.public_bucket_name
    private_bucket_name = module.storage.private_bucket_name
    visible_bucket_name = module.storage.visible_bucket_name
    cloudfront_domain   = module.storage.cloudfront_domain_name
  }
}

output "iam_group_name" {
  description = "Name of the IAM group"
  value       = module.iam.group_name
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy"
  value       = module.iam.policy_arn
}
