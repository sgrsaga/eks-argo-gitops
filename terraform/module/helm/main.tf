# Helm Provide config

provider "helm" {
  kubernetes {
    # config_path = var.config_path
    # Use Exec plugins
    host = module.k8s.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.cert_data)  # module.k8s.kubeconfig-certificate-authority-data
    exec {
      api_version = "client.authentication.k8s.io/v1beta1" 
      args = ["eks", "get-token", "--cluster-name", var.cluster_name] 
      command = "aws"
    }
  }
}