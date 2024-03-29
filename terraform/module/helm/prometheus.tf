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
    version = "55.7.0"

    # Set replicas
    set {
        name  = "replicas"
        value = "2"
    }
    # Disable Grafana since we have Grafana seperately
    set {
        name  = "grafana.enabled"
        value = "false"
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
    # Set Node Selector to Utility nodes
    set {
        name = "prometheusOperator.admissionWebhooks.deployment.nodeSelector.category"
        value = "utility"
        type = "string"
    }
    set {
        name = "prometheusOperator.nodeSelector.category"
        value = "utility"
        type = "string"
    }
    set {
        name = "alertmanager.alertmanagerSpec.nodeSelector.category"
        value = "utility"
        type = "string"
    }
    ## Replicas set
    set {
        name = "alertmanager.alertmanagerSpec.replicas"
        value = "2"
    }
    set {
        name = "prometheusOperator.admissionWebhooks.deployment.replicas"
        value = "2"
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