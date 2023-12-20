# Ingress namesapce
output "ingress_ns"{
    value = kubernetes_namespace.ingress.metadata.0.name
}