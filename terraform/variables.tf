variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "ecommerce"
}

variable "environment" {
  description = "Environment: dev, staging, prod"
  type        = string
  default     = "prod"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS node group"
  type        = string
  default     = "t3.medium"
}

variable "eks_min_nodes" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 2
}

variable "eks_max_nodes" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 6
}

variable "eks_desired_nodes" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 3
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS (GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ecommercedb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password (sensitive)"
  type        = string
  sensitive   = true
}

variable "backup_bucket_name" {
  description = "Name of S3 bucket for backups (Velero)"
  type        = string
  default     = "ecommerce-backups-prod"
}