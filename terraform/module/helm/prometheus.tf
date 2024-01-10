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
    chart = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
    version = "25.8.2"

    # Set replicas
    set {
        name  = "replicas"
        value = "2"
    }
    # Set alertmanager.persistentVolume.storageClass
    set {
        name = "alertmanager.persistentVolume.storageClass"
        value = "gp2"
        type = "string"
    }
    # Set server.persistentVolume.storageClass
    set {
        name = "server.persistentVolume.storageClass"
        value = "gp2"
        type = "string"
    }
    # Set Node Selector to Utility nodes
    set {
        name = "nodeSelector.category"
        value = "utility"
        type = "string"
    }
    # # Set Tollerations to host in utility node group
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
}