#######################################
## Install required resources for Grafana with helm
#######################################


# Install Grafana helm chart
resource "helm_release" "grafana" {
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

## Apply below configuration parameters for the grafana.ini via [grafana] ConfigMap
#   grafana.ini: |
#     [analytics]
#     check_for_updates = true
#     [grafana_net]
#     url = https://grafana.net
#     [log]
#     mode = console
#     [paths]
#     data = /var/lib/grafana/
#     logs = /var/log/grafana
#     plugins = /var/lib/grafana/plugins
#     provisioning = /etc/grafana/provisioning
#     [users]
#     allow_sign_up = true
#     auto_assign_org = true
#     auto_assign_org_id = 1
#     allow_org_create = true
#     [server]
#     domain = 'grafana.devops-expert.foundation'
#     root_url = %(protocol)s://%(domain)s:%(http_port)s/

