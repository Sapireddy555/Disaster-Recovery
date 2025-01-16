module "multi_region_s3" {
  source = "./modules/multi-region-s3"

  primary_bucket_name   = "primary-bucket"
  secondary_bucket_name = "secondary-bucket"
  replication_role_arn  = aws_iam_role.replication_role.arn
}

resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "replication_policy" {
  name = "s3-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:GetReplicationConfiguration"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication_policy_attach" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}
