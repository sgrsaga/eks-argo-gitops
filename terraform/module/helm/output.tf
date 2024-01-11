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
## Get Zone ID
output "zone_id" {
    value = data.aws_route53_zone.dns_zone.id
}
## Get Zone ID
output "arns_list" {
    value = data.aws_lbs.nlb.arns
}

output "nlb_dns_name" {
    value = data.aws_lb.get_nlb_dns_name.dns_name
}