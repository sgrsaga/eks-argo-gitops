# We will apply the relevant DNS records for the Ingress rules

# 1. Get the Route 53c Zone ID
data "aws_route53_zone" "dns_zone" {
  name         = var.domain_name_used
  private_zone = true
}

## Get Zone ID
output "zone_id" {
    value = data.aws_route53_zone.dns_zone.id
}

# 2. Get the AWS NLB arn
data "aws_lbs" "nlb" {
  tags = {
    "nlb_name" = "nginx_ingress_controller_nlb"
  }
  depends_on = [ helm_release.nginx_ingress ]
}

data "aws_lb" "test" {
  arn  = "${element(data.aws_lbs.nlb.arns, 0)}"  ##element(list, 0 )
  depends_on = [ helm_release.nginx_ingress ]
}

output "nlb_dns_name" {
    value = data.aws_lb.test.dns_name
}

# 3. Create Simple routing with DNS names
resource "aws_route53_record" "ingres_routes" {
    count = length(var.alt_names)
      zone_id = "${data.aws_route53_zone.dns_zone.id}"
      name    = var.alt_names[count.index]
      type    = "A"


      alias {
        name =  data.aws_lb.test.dns_name
        zone_id = aws_elb.main.zone_id
        evaluate_target_health = true
      }

    depends_on = [ helm_release.nginx_ingress ]
}