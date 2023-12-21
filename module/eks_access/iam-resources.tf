# IAM Policy to attach to EKS Developer role
resource "aws_iam_group_policy" "developer_group_policy" {
  name        = "developer_group_policy"
  group = aws_iam_group.developers.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"eks:ListFargateProfiles",
				"eks:DescribeNodegroup",
				"eks:ListUpdates",
				"eks:AccessKubernetesApi",
				"eks:DescribeCluster",
				"eks:ListClusters",
				"ssm:GetParameter"
			],
			"Resource": "*"
		}
	]
})
}

# Create Group Developers
resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/"
}

# Attach the Developer Policy to Developer Group
resource "aws_iam_group_policy_attachment" "developer_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_group_policy.developer_group_policy.arn
}

# Create 1 Developer role
resource "aws_iam_user" "developer" {
  name = "developer1"
  path = "/"

  tags = {
    Type = "Developer"
    Access = "ReadOnly" 
  }
}

resource "aws_iam_group_membership" "developer_team" {
  name = "developer-group-membership"

  users = [
    aws_iam_user.developer.name,
  ]

  group = aws_iam_group.developers.name
}