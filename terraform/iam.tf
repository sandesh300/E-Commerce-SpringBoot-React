data "aws_iam_policy_document" "velero_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]   # Velero runs on EKS nodes; use IRSA instead
    }
    actions = ["sts:AssumeRole"]
  }
}

# For IRSA, we'll create a policy and attach it to a Kubernetes service account
resource "aws_iam_policy" "velero_s3_policy" {
  name        = "${var.project_name}-velero-s3-policy"
  description = "Allow Velero to manage S3 backups"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*"
        ]
      }
    ]
  })
}

