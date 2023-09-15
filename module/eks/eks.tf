# 01. IAM role for EKS cluster
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect        = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_iam_role" {
  name               = "eks_iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "RolePolicy-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_iam_role.name
}

# 02. MKS key for EKS resource encryption for security
resource "aws_kms_key" "eks_new_key" {
  description               = "EKS KMS Key"
  enable_key_rotation       = true
  deletion_window_in_days   = 7  # Set the desired deletion window (7 to 30 days)

  policy                    = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"kms:GetParametersForImport",
				"kms:GetPublicKey",
				"kms:TagResource",
				"kms:UntagResource",
				"kms:ListKeyPolicies",
				"kms:ListRetirableGrants",
				"kms:GetKeyRotationStatus",
				"kms:GetKeyPolicy",
				"kms:DescribeKey",
				"kms:ListResourceTags",
				"kms:ListGrants"
			],
			"Resource": "arn:aws:kms:*:598792377165:key/*"
		},
		{
			"Sid": "VisualEditor1",
			"Effect": "Allow",
			"Action": [
				"kms:DescribeCustomKeyStores",
				"kms:ListKeys",
				"kms:ListAliases"
			],
			"Resource": "*"
		}
	]
}
EOF
}




# EKS Cluster resource
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_iam_role.arn

  vpc_config {
    subnet_ids              = var.cluster_subnets
    security_group_ids      = ["${var.cluster_security_group}"]
    endpoint_public_access  = false
  }
  encryption_config {
    resources               = ["secrets"]
    provider {
      key_arn               = aws_kms_key.eks_new_key.arn
    }
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on                = [
    aws_iam_role_policy_attachment.RolePolicy-AmazonEKSClusterPolicy,
  ]
}


# Enable IAM Roles for Service Accounts
data "tls_certificate" "tls_cert" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_iam_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_cert.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.tls_cert.url
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test      = "StringEquals"
      variable  = "${replace(aws_iam_openid_connect_provider.oidc_iam_provider.url, "https://", "")}:sub"
      values    = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_iam_provider.arn]
      type        = "Federated"
    }
  }
  depends_on = [ aws_iam_openid_connect_provider.oidc_iam_provider ]
}

resource "aws_iam_role" "oidc_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "oidc_role_service_account"
}