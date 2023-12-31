# IAM Policy to attach to EKS Developer role
resource "aws_iam_group_policy" "admin_group_policy" {
  name        = "eks_admin_group_policy"
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
		},
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"iam:PassRole"
			],
			"Resource": [
				"*"
			],
			"Condition": {
				"StringEquals": {
					"iam:PassedToService": "eks.amazon.com"
				}
			}
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


# # IAM Policy to attach to EKS Developer role
# resource "aws_iam_policy" "admin_assume_policy" {
#   name        = "eks_admin_group_policy"
#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": "sts:AssumeRole",
#             "Resource": "arn:aws:iam::598792377165:user/terra-test-user"
#         }
#     ]
# })
# }


# ## Create IAM Admin role
# resource "aws_iam_role" "eksAdminRole" {
#   name = "eksAdminRole"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
# 	"Version": "2012-10-17",
# 	"Statement": [
# 		{
# 			"Sid": "VisualEditor",
# 			"Effect": "Allow",
# 			"Action": [
# 				"eks:*",
# 				"ssm:*"
# 			],
# 			"Resource": "*"
# 		},
# 		{
# 			"Sid": "Statement1",
# 			"Effect": "Allow",
# 			"Action": [
# 				"iam:PassRole"
# 			],
# 			"Resource": [
# 				"*"
# 			],
# 			"Condition": {
# 				"StringEquals": {
# 					"iam:PassedToService": "eks.amazon.com"
# 				}
# 			}
# 		}
# 	]
# })
# }

# # Create Group Developers
# resource "aws_iam_group" "eks_admins" {
#   name = "eks_admins"
#   path = "/"
# }

# # Attach the Developer Policy to Developer Group
# resource "aws_iam_group_policy_attachment" "admin_policy_attach" {
#   group      = aws_iam_group.eks_admins.name
#   policy_arn = aws_iam_policy.admin_assume_policy.arn
# }

# # Create 1 Developer role
# resource "aws_iam_user" "eks_admin" {
#   name = var.adminuser
#   path = "/"

#   tags = {
#     Type = "Admin"
#     Access = "FullAccess" 
#   }
# }

# resource "aws_iam_group_membership" "eks_admins_team" {
#   name = "eks_admins-group-membership"

#   users = [
#     aws_iam_user.eks_admin.name,
#   ]

#   group = aws_iam_group.eks_admins.name
# }

