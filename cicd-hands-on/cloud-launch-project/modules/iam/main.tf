# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for current AWS region
data "aws_region" "current" {}

data "aws_iam_policy_document" "vpc_s3_policy_doc" {
  statement {
    sid = "VPCResourceRead"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeDhcpOptions"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      variable = "ec2:vpc"
      values   = [var.vpc_arn]
    }
  }

  statement {
    sid       = "S3ListBuckets"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "S3PublicBucketAccess"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::${var.public_bucket}",
      "arn:aws:s3:::${var.public_bucket}/*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "S3PrivateBucketAccess"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${var.private_bucket}",
      "arn:aws:s3:::${var.private_bucket}/*"
    ]
    effect = "Allow"
  }

  statement {
    sid     = "S3VisibleBucketDeny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.visible_bucket}",
      "arn:aws:s3:::${var.visible_bucket}/*"
    ]
    effect = "Deny"
  }

  statement {
    sid = "DenyS3Delete"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.public_bucket}/*",
      "arn:aws:s3:::${var.private_bucket}/*",
      "arn:aws:s3:::${var.visible_bucket}/*",
      "arn:aws:s3:::${var.public_bucket}",
      "arn:aws:s3:::${var.private_bucket}",
      "arn:aws:s3:::${var.visible_bucket}"
    ]
    effect = "Deny"
  }

}

# IAM Policy for VPC and S3 access
resource "aws_iam_policy" "vpc_s3_policy" {
  name        = "${var.project_name}-${var.environment}-vpc-s3-policy"
  description = "Policy for VPC resource read access and specific S3 permissions"

  policy = data.aws_iam_policy_document.vpc_s3_policy_doc.json
}

# IAM Group for users who need the defined permissions
resource "aws_iam_group" "app_users_group" {
  name = "${var.project_name}-${var.environment}-app-users"
}

# Attach the policy to the group
resource "aws_iam_group_policy_attachment" "vpc_s3_policy_attachment" {
  group      = aws_iam_group.app_users_group.name
  policy_arn = aws_iam_policy.vpc_s3_policy.arn
}
