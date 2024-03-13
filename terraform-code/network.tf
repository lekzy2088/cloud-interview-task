# Create a VPC
module "flask_app_vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  name           = "new-flask-app-vpc"
  cidr           = "10.1.0.0/16"
  azs            = ["eu-west-2a", "eu-west-2b"]
  public_subnets = ["10.1.101.0/24", "10.1.102.0/24"]
  tags = {
    Terraform = "true"
  }
}

# Create Route53 Record
resource "aws_route53_record" "alb_rout53_record" {
  zone_id = var.zone_id
  name    = "makers.${var.domain}"
  type    = "A"

  alias {
    name                   = module.flask_app_alb.lb_dns_name
    zone_id                = module.flask_app_alb.lb_zone_id
    evaluate_target_health = true
  }
}