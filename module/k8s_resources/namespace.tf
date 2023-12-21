# Create name space for Ingress Controller
resource "kubernetes_namespace" "ingress" {  
  metadata {
    name = var.ingress_ns
  }
}

# Create namespace for argo
resource "kubernetes_namespace" "argo" {  
  metadata {
    name = var.argo_ns
  }
}

# Create namespace for monitoring
resource "kubernetes_namespace" "monitoring" {  
  metadata {
    name = var.monitoring_ns
  }
}
