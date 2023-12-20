# Create name space for Ingress Controller
resource "kubernetes_namespace" "ingress" {  
  metadata {
    name = var.ingress_ns
  }
}

