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
        name  = "server.replicas"
        value = "2"
    }
  # Set Node Selector to Utility nodes
  set {
    name = "global.nodeSelector.category"
    value = "utility"
    type = "string"
  }
    # # Set global Tollerations to host in utility node group
    # set {
    #   name  = "global.tolerations[0].key"
    #   value = "utility"
    # }
    # set {
    #   name  = "global.tolerations[0].value"
    #   value = "no"
    # }
    # set {
    #   name  = "global.tolerations[0].operator"
    #   value = "Equal"
    # }
    # set {
    #   name  = "global.tolerations[0].effect"
    #   value = "NoSchedule"
    # }
    # # Set Controller Tollerations to host in utility node group
    # set {
    #   name  = "controller.tolerations[0].key"
    #   value = "utility"
    # }
    # set {
    #   name  = "controller.tolerations[0].value"
    #   value = "no"
    # }
    # set {
    #   name  = "controller.tolerations[0].operator"
    #   value = "Equal"
    # }
    # set {
    #   name  = "controller.tolerations[0].effect"
    #   value = "NoSchedule"
    # }
    # # Set Redis Tollerations to host in utility node group
    # set {
    #   name  = "redis.tolerations[0].key"
    #   value = "utility"
    # }
    # set {
    #   name  = "redis.tolerations[0].value"
    #   value = "no"
    # }
    # set {
    #   name  = "redis.tolerations[0].operator"
    #   value = "Equal"
    # }
    # set {
    #   name  = "redis.tolerations[0].effect"
    #   value = "NoSchedule"
    # }
    # # Set Server Tollerations to host in utility node group
    # set {
    #   name  = "server.tolerations[0].key"
    #   value = "utility"
    # }
    # set {
    #   name  = "server.tolerations[0].value"
    #   value = "no"
    # }
    # set {
    #   name  = "server.tolerations[0].operator"
    #   value = "Equal"
    # }
    # set {
    #   name  = "server.tolerations[0].effect"
    #   value = "NoSchedule"
    # }
    # Dependency with nginx ingress controller
    depends_on = [ helm_release.nginx_ingress ]
}

