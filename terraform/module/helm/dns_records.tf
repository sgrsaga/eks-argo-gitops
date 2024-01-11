# We will apply the relevant DNS records for the Ingress rules

# 1. Get the Route 53c Zone ID
data "aws_route53_zone" "dns_zone" {
  name         = var.domain_name_used
  private_zone = false
}

# 2. Get the AWS NLB arn
data "aws_lbs" "nlb" {
  tags = {
    "kubernetes.io/service-name" = "ingress/nginx-ingress-controller-ingress-nginx-controller"
  }
  depends_on = [ helm_release.nginx_ingress ]
}

data "aws_lb" "get_nlb_dns_name" {
  arn  = element(tolist(data.aws_lbs.nlb.arns),0)  ##element(list_data, 0 )
  depends_on = [ helm_release.nginx_ingress ]
}

# 3. Create Simple routing with DNS names
resource "aws_route53_record" "ingres_routes" {
    count = length(var.alt_names)
      zone_id = data.aws_route53_zone.dns_zone.id
      name    = var.alt_names[count.index]
      type    = "A"
    #   ttl = 300
    #   records = [data.aws_lb.get_nlb_dns_name.dns_name]
      alias {
        name =  data.aws_lb.get_nlb_dns_name.dns_name
        zone_id = var.alias_zone_id
        evaluate_target_health = true
      }

    depends_on = [ helm_release.nginx_ingress ]
}