resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }
}


resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
  create_namespace = false
  # Pin versions intentionally (upgrade intentionally)
  version = "9.2.3"

  # Minimal but sane defaults
  values = [
    yamlencode({
      global = {
        # optional: set a cluster domain if different
        # domain = "cluster.local"
      }

      configs = {
        params = {
          # Recommended behind ingress/ALB so ArgoCD generates correct URLs
          "server.insecure" = true
        }
      }

      server = {
        replicas = 1
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace_v1.argocd]
}
