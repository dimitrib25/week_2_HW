# Create IAM groups for each environment
resource "aws_iam_group" "environment_group" {
  for_each = toset(["development", "staging", "production"])
  name     = "${each.value}-group"
}
# Define custom policy documents for each environment
data "aws_iam_policy_document" "custom_policy_doc" {
  for_each = {
    development = {
      actions   = ["ec2:*", "s3:ListBucket", "s3:GetObject"]
      resources = ["arn:aws:s3:::example-development-bucket/*"]
    },
    staging = {
      actions   = [
        "s3:ListBucket",
        "logs:CreateExportTask",
        "logs:CancelExportTask",
        "logs:DescribeExportTasks",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups"
      ]
      resources = ["arn:aws:s3:::example-staging-bucket/*"]
    },
    production = {
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::example-production-bucket/*"]
    }
  }
  statement {
    actions   = each.value.actions
    resources = each.value.resources
    effect    = "Allow"
  }
}
# Create custom IAM policies from policy documents
resource "aws_iam_policy" "custom_policy" {
  for_each = data.aws_iam_policy_document.custom_policy_doc
  name     = "${each.key}-policy"
  policy   = each.value.json
} 
# Create IAM users and assign to groups as before
resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.key
} 
resource "aws_iam_group_membership" "user_group_membership" {
  for_each = var.users
  name  = "${each.key}-membership"
  users = [aws_iam_user.users[each.key].name]
  group = "${each.value}-group"
}


# Output 
/*output "iam_groups_arns" {
  value = [
    aws_iam_group.development_group.arn,
    aws_iam_group.staging_group.arn,
    aws_iam_group.production_group.arn,
  ]
}*/

output "iam_users_arns" {
  value = [
    aws_iam_user.users.users
  ]
}
