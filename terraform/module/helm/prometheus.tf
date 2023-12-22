#######################################
## Install required resources for Prometheus with helm
#######################################

# Install ArgoCD helm chart
resource "helm_release" "prometheus" {
    name = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "prometheus"
    namespace = var.monitoring_ns
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
}