#######################################
## Install required resources for ArgoCD with helm
#######################################

# Install ArgoCD helm chart
resource "helm_release" "argocd" {
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    namesapce = var.argo_ns
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
}