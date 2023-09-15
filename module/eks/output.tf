# EKS Cluster End point
output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}


## KMS Key ID for EKS cluster
output "eks_key_id" {
  value = aws_kms_key.eks_new_key.key_id
}
