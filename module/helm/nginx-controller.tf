
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

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}