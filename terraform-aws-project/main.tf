# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"  # Change this to your preferred AWS region
}

# Step 1: Create IAM User "Batman" with EC2 Full Access
resource "aws_iam_user" "batman" {
  name = "Batman"
}

# Attach EC2 Full Access Policy to Batman
resource "aws_iam_user_policy_attachment" "batman_ec2_full_access" {
  user       = aws_iam_user.batman.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Step 2: Create IAM Group "batcave"
resource "aws_iam_group" "batcave" {
  name = "batcave"
}

# Step 3: Add Batman to the "batcave" Group
resource "aws_iam_group_membership" "batcave_members" {
  name  = "batcave-membership" # Provide a unique name for the membership
  group = aws_iam_group.batcave.name
  users = [
    aws_iam_user.batman.name,
    aws_iam_user.robin.name
  ]
}

# Attach IAM Full Access Policy to Batcave Group
resource "aws_iam_group_policy_attachment" "batcave_iam_full_access" {
  group      = aws_iam_group.batcave.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# Step 4: Create IAM User "Robin" with Lambda Full Access
resource "aws_iam_user" "robin" {
  name = "Robin"
}

# Attach Lambda Full Access Policy to Robin
resource "aws_iam_user_policy_attachment" "robin_lambda_full_access" {
  user       = aws_iam_user.robin.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Step 5: Create an S3 Bucket (example resource)
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-terraform-example-bucket"  # Ensure this bucket name is globally unique
  acl    = "private"
}

# Step 6: Create IAM User "Alfred" with EC2 and Lambda Full Access
resource "aws_iam_user" "alfred" {
  name = "Alfred"
}

# Attach EC2 Full Access Policy to Alfred
resource "aws_iam_user_policy_attachment" "alfred_ec2_full_access" {
  user       = aws_iam_user.alfred.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Attach Lambda Full Access Policy to Alfred
resource "aws_iam_user_policy_attachment" "alfred_lambda_full_access" {
  user       = aws_iam_user.alfred.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Step 7: Create IAM Role for Lambda to Read DynamoDB
resource "aws_iam_role" "lambda_dynamodb_read" {
  name = "LambdaDynamoDBReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_read_policy" {
  role       = aws_iam_role.lambda_dynamodb_read.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

# Step 8: Create IAM Role for Lambda to Read/Write DynamoDB & Manage EventBridge
resource "aws_iam_role" "lambda_dynamodb_eventbridge" {
  name = "LambdaDynamoDBEventBridgeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_eventbridge_policy" {
  role       = aws_iam_role.lambda_dynamodb_eventbridge.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_eventbridge_policy" {
  role       = aws_iam_role.lambda_dynamodb_eventbridge.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}
