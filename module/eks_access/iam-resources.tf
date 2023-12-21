# IAM Policy to attach to EKS Developer role
resource "aws_iam_policy" "policy" {
  name        = "developer_policy"
  path        = "/"
  description = "Developer policy"

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
resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = aws_iam_group.group.developers
  policy_arn = aws_iam_policy.policy.arn
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