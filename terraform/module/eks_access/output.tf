# Developer role ARN
output "dev1_arn" {
  value = aws_iam_user.developer.arn
}

# Admin role ARN
output "admin1_arn" {
  value = aws_iam_user.eks_admin.arn
}