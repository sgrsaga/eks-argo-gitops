# EKS Cluster End point
output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

## EKS Cluster Name
output "eks_cluster_name" { 
  value = aws_eks_cluster.eks_cluster.name
}

## KMS Key ID for EKS cluster
output "eks_key_id" {
  value = aws_kms_key.eks_new_key.key_id
}


# EKS cluster endpoiny
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
  
}

# OIDC IAM Provider ARN and URL
output "oidc_iam_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc_iam_provider.arn
}

# OIDC IAM Provider URL
output "oidc_iam_provider_url" {
  value = aws_iam_openid_connect_provider.oidc_iam_provider.url
}
