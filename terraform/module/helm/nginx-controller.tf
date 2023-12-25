#######################################
## Install required resources for nginx controller with helm
#######################################


# Create name space for Ingress Controller
resource "kubernetes_namespace" "ingress" {  
  metadata {
    name = var.ingress_ns
  }
}

# Install Nginx Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"

  namespace = kubernetes_namespace.ingress.metadata.0.name

  ## Custom config values
  values = [
    "${file("nginx-ingress-values.yaml")}"
  ]

  # Spin up a AWS ALB
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  # Set replicas
  set {
    name  = "replicas"
    value = "2"
  }
  # Export metrics from nginx controller to prometheus
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
    type  = "string"
  }
  # Set Node Selector to Utility nodes
  set {
    name = "nodeSelector.category"
    value = "utility"
    type = "string"
  }
  # Set Resource limit for the nginx controller
  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}