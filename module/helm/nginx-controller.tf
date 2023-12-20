
# Create name space for Ingress Controller
resource "kubernetes_namespace" "ingress" {  
  metadata {
    name = "ingress"
  }
}

# Install Nginx Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"

  namespace = kubernetes_namespace.ingress.metadata.0.name

  # Spin up a AWS ALB
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  # Export metrics from nginx controller to prometheus
  # set {
  #   name  = "controller.metrics.enabled"
  #   value = "true"
  # }
  # set {
  #   name  = "controller.podAnnotations.'prometheus\.io/scrape'"
  #   value = "true"
  # }
  # set {
  #   name  = "controller.metrics.enabled"
  #   value = "true"
  # }
}