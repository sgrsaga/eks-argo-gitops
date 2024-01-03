#######################################
## Install required resources for Grafana with helm
#######################################


# Install Grafana helm chart
resource "helm_release" "argocd" {
    name = "grafana"
    repository = "https://grafana.github.io/helm-charts"
    chart = "grafana"
    namespace = var.monitoring_ns
    version = "7.0.19"

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