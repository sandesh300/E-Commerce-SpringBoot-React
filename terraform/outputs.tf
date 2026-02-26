output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "rds_primary_endpoint" {
  description = "Primary RDS instance endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "rds_replica_endpoint" {
  description = "Read replica RDS instance endpoint"
  value       = aws_db_instance.read_replica.endpoint
}

output "backup_bucket_arn" {
  description = "S3 bucket ARN for backups"
  value       = aws_s3_bucket.backups.arn
}