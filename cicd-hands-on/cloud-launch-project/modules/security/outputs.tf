output "app_security_group_id" {
  description = "ID of the app security group"
  value       = aws_security_group.app.id
}

output "app_security_group_arn" {
  description = "ARN of the app security group"
  value       = aws_security_group.app.arn
}

output "db_security_group_id" {
  description = "ID of the db security group"
  value       = aws_security_group.db.id
}

output "db_security_group_arn" {
  description = "ARN of the db security group"
  value       = aws_security_group.db.arn
}
