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
    # Set Tollerations to host in utility node group
    set {
      name  = "tolerations[0].key"
      value = "utility"
    }

    set {
      name  = "tolerations[1].value"
      value = "yes"
    }

    set {
      name  = "tolerations[2].operator"
      value = "Equal"
    }

    set {
      name  = "tolerations[3].effect"
      value = "PREFER_NO_SCHEDULE"
    }

    # Dependency with nginx ingress controller
    depends_on = [ helm_release.nginx_ingress ]
}

