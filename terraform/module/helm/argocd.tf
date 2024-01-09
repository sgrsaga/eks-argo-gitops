#######################################
## Install required resources for ArgoCD with helm
#######################################

# Create namespace for argo
resource "kubernetes_namespace" "argo" {  
  metadata {
    name = var.argo_ns
  }
}

# Install ArgoCD helm chart
resource "helm_release" "argocd" {
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    namespace = kubernetes_namespace.argo.metadata.0.name
    version = "5.51.6"

    # Set replicas
    set {
        name  = "replicas"
        value = "2"
    }
    # Set Node Selector to Utility nodes
    set {
        name = "nodeSelector.category"
        value = "utility"
        type = "string"
    }

    # Dependency with nginx ingress controller
    depends_on = [ helm_release.nginx_ingress ]
}