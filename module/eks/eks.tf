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
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/k8s-master-key"
  target_key_id = aws_kms_key.eks_new_key.key_id
}

# Get the subnet list
data "aws_subnets" "all_subnet" {
  filter {
    name   = "Type"
    values = ["SUBNET"]
  }
}

# Get Securiy Group
data "aws_security_groups" "all_sg" {
  filter {
    name   = "Type"
    values = ["SECURITY_GROUP"]
  }
}
#######################
# EKS Cluster resource
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_iam_role.arn

  vpc_config {
    subnet_ids              = data.aws_subnets.all_subnet.ids
    security_group_ids      = data.aws_security_groups.all_sg.ids
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs = ["0.0.0.0/0"]
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

# Create IAM Role for EKS Node Group
resource "aws_iam_role" "ng_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ng-policy-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ng_role.name
}

resource "aws_iam_role_policy_attachment" "ng-policy-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ng_role.name
}

resource "aws_iam_role_policy_attachment" "ng-policy-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ng_role.name
}

# Create Node Group
resource "aws_eks_node_group" "node_groups" {
  count = length(var.node_group_names)
    cluster_name    = aws_eks_cluster.eks_cluster.name
    node_group_name = "${var.node_group_names[count.index]}"
    node_role_arn   = aws_iam_role.ng_role.arn
    subnet_ids      = var.cluster_subnets

    scaling_config {
        desired_size = "${var.node_group_size[0]}"
        max_size     = "${var.node_group_size[1]}"
        min_size     = "${var.node_group_size[2]}"
    }

    update_config {
        max_unavailable = "${var.node_group_size[3]}"
    }
    tags = {
      Name = "${var.node_group_names[count.index]}"
      Type = "NodeGroup"
    }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.ng-policy-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.ng-policy-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.ng-policy-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Install Add-ons install

# CNI plugin
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
}
# CoreDNS plugin
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"
}
# kube-proxy plugin
resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"
}
