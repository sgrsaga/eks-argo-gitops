## AWS Load Balancer Controller Policy
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name   = "${var.eks_cluster_name}-AWSLoadBalancerControllerPolicy"
  policy = file("${path.module}/iam/aws-load-balancer-controller-policy.json")
}


locals {
  oidc_provider_url = replace(var.oidc_iam_provider_url, "https://", "")
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${var.eks_cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_iam_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = "system:serviceaccount:*:aws-load-balancer-controller"
          "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}


resource "kubernetes_namespace_v1" "ingress_ns" {
  metadata {
    name = var.ingress_ns
    labels = {
      "app.kubernetes.io/part-of" = "ingress"
    }
  }
}

# AWS Load Balancer Controller Helm Release
resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  create_namespace = false
  namespace        = kubernetes_namespace_v1.ingress_ns.metadata[0].name
  version          = "1.17.0" # pick a known version, upgrade intentionally

  values = [
    yamlencode({
      clusterName = var.eks_cluster_name

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
        }
      }

    #   # Optional, but recommended for EKS:
      region = var.cluster_region
      vpcId  = var.cluster_vpc_id  # Use the actual VPC ID from main_network module
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}
