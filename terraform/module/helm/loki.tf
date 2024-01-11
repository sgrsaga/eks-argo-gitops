#######################################
## Install required resources for Grafana Loki with helm
#######################################


# Install Grafana helm chart
resource "helm_release" "loki" {
    name = "loki"
    repository = "https://grafana.github.io/helm-charts"
    chart = "loki-stack"
    namespace = var.monitoring_ns
    version = "2.9.11"

    # # Set replicas
    # set {
    #     name  = "replicas"
    #     value = "2"
    # }
    # Set Node Selector to Utility nodes
    set {
        name = "nodeSelector.category"
        value = "utility"
        type = "string"
    }
    # enable fluent-bit
    set {
        name = "fluent-bit.enabled"
        value = "false"
    }
    # enable fluent-bit
    set {
        name = "promtail.enabled"
        value = "true"
    }
    # enable grafana
    set {
        name = "grafana.enabled"
        value = "true"
    }
    # # Set Tollerations to host in utility node group
    # set {
    #   name  = "tolerations[0].key"
    #   value = "utility"
    # }
    # set {
    #   name  = "tolerations[0].value"
    #   value = "no"
    # }
    # set {
    #   name  = "tolerations[0].operator"
    #   value = "Equal"
    # }
    # set {
    #   name  = "tolerations[0].effect"
    #   value = "NoSchedule"
    # }
}
