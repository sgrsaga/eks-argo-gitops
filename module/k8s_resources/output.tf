# Ingress namesapce
output "ingress_ns"{
    value = kubernetes_namespace.ingress.metadata.0.name
}


# ArgoCD namesapce
output "argo_ns"{
    value = kubernetes_namespace.argo.metadata.0.name
}