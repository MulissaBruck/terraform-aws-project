# Provider configuration
provider "aws" {
  region = "us-east-1"  # Set the correct region
}

# Create IAM User (bruk)
resource "aws_iam_user" "bruk_user" {
  name = "bruk"
}

# Tagging the IAM user with Role=Admin
resource "aws_iam_user_tag" "bruk_user_tag" {
  user = aws_iam_user.bruk_user.name
  key   = "Role"
  value = "Admin"
}

# Create SystemAdmin IAM Role (Allows all IAM users to use it)
resource "aws_iam_role" "system_admin_role" {
  name               = "SystemAdmin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonEC2FullAccess and AmazonDynamoDBReadOnlyAccess to SystemAdmin role
resource "aws_iam_role_policy_attachment" "system_admin_ec2" {
  role       = aws_iam_role.system_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "system_admin_dynamodb" {
  role       = aws_iam_role.system_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

# Create DbAdmin IAM Role (Allows individual IAM users to use it)
resource "aws_iam_role" "db_admin_role" {
  name               = "DbAdmin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/bruk"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonDynamoDBFullAccess to DbAdmin role
resource "aws_iam_role_policy_attachment" "db_admin_dynamodb" {
  role       = aws_iam_role.db_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Create ABAC IAM Policy
resource "aws_iam_policy" "abac_policy" {
  name        = "ABACPolicy"
  description = "ABAC policy that allows actions based on tags"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/Role" = "Admin"
          }
        }
      }
    ]
  })
}

# Attach the ABAC policy to the IAM user (bruk)
resource "aws_iam_user_policy_attachment" "bruk_user_policy" {
  user       = aws_iam_user.bruk_user.name
  policy_arn = aws_iam_policy.abac_policy.arn
}

# Output the IAM user and roles
output "bruk_user" {
  value = aws_iam_user.bruk_user.name
}

output "system_admin_role" {
  value = aws_iam_role.system_admin_role.name
}

output "db_admin_role" {
  value = aws_iam_role.db_admin_role.name
}
