#######################################
## Install required resources for Prometheus with helm
#######################################

# Create namespace for monitoring
resource "kubernetes_namespace" "monitoring" {  
  metadata {
    name = var.monitoring_ns
  }
}


# Install Prometheus helm chart
resource "helm_release" "prometheus" {
    name = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
    version = "55.5.0"

    # Set grafana enabling
    set {
        name  = "grafana.enabled"
        value = "true"
    }
    # Set grafana ingress enabling
    set {
        name  = "grafana.ingress.ingressClassName"
        value = "nginx"
    }
    # Set grafana ingress path
    set {
        name  = "grafana.ingress.path"
        value = "/(.*)" # /grafana/?(.*)
    }
    # # Set alertmanager.persistentVolume.storageClass
    # set {
    #     name = "alertmanager.persistentVolume.storageClass"
    #     value = "gp2"
    #     type = "string"
    # }
    # # Set server.persistentVolume.storageClass
    # set {
    #     name = "server.persistentVolume.storageClass"
    #     value = "gp2"
    #     type = "string"
    # }
    # # Set Node Selector to Utility nodes
    set {
        name = "nodeSelector"
        value = "category: utility"
        type = "string"
    }
}