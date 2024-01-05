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
  version    = "4.9.0"

  namespace = kubernetes_namespace.ingress.metadata.0.name

  # Spin up a AWS ALB
  set {
    name  = "service.type"
    value = "LoadBalancer"
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
    name = "controller.nodeSelector.category"
    value = "utility"
    type = "string"
  }
  # Set Autoscaling
  set {
    name = "controller.autoscaling.enabled"
    value = "true"
  }
  # Set Min Pods # Set replicas
  set {
    name = "controller.autoscaling.minReplicas"
    value = 2
  }
  # Set to Network load balancer snnotations
  ##############################
  set {
    name = "service.annotations.service\\.beta.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
  }
  set {
    name = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }
  set {
    name = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout"
    value = "60"
  }
  set {
    name = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  # Set  --enable-ssl-passthrough for argocd (Setting this manually)
  # Note that the nginx.ingress.kubernetes.io/ssl-passthrough annotation requires that the --enable-ssl-passthrough flag be added to the command line arguments to nginx-ingress-controller
  # set_list {
  #   name = "controller.extraArgs"
  #   value = ["--enable-ssl-passthrough"]
  # }
}