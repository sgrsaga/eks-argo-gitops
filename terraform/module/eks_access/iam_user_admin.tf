# IAM Policy to attach to EKS Developer role
resource "aws_iam_group_policy" "admin_group_policy" {
  name        = "admin_group_policy"
  group = aws_iam_group.eks_admins.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor",
			"Effect": "Allow",
			"Action": [
				"eks:*",
				"ssm:*"
			],
			"Resource": "*"
		}
	]
})
}

# Create Group Developers
resource "aws_iam_group" "eks_admins" {
  name = "eks_admins"
  path = "/"
}

# Attach the Developer Policy to Developer Group
# resource "aws_iam_group_policy_attachment" "developer_attach" {
#   group      = aws_iam_group.developers.name
#   policy_arn = aws_iam_group_policy.developer_group_policy.name
# }

# Create 1 Developer role
resource "aws_iam_user" "eks_admin" {
  name = var.adminuser
  path = "/"

  tags = {
    Type = "Admin"
    Access = "FullAccess" 
  }
}

resource "aws_iam_group_membership" "eks_admins_team" {
  name = "eks_admins-group-membership"

  users = [
    aws_iam_user.eks_admin.name,
  ]

  group = aws_iam_group.eks_admins.name
}

