# Ingress namesapce
output "ingress_ns"{
    value = kubernetes_namespace.ingress.metadata.0.name
}


# ArgoCD namesapce
output "argo_ns"{
    value = kubernetes_namespace.argo.metadata.0.name
}


# # Monitoring namesapce
# output "monitoring_ns"{
#     value = kubernetes_namespace.monitoring.metadata.0.name
# }

## Check Argo manifest file
output "manifest_files" {
  value = helm_release.argocd.manifest
}

## Final Values
output "final_values" {
  value = helm_release.argocd.values
}