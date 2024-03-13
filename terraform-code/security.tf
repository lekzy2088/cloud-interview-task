# Create a security group for the ECS tasks
resource "aws_security_group" "flask_app_ecs_sg" {
  name        = "ecs-security-group"
  description = "Security group for ECS tasks"
  vpc_id      = module.flask_app_vpc.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.flask_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create security group for alb
resource "aws_security_group" "flask_alb_sg" {
  name        = "flask-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.flask_app_vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# request for Certificate
module "acm_cert_request" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain
  zone_id     = var.zone_id

  subject_alternative_names = [
    "*.${var.domain}"
  ]

  wait_for_validation = true

  tags = {
    Terraform = "true"
  }
}

# create alb for traffic
module "flask_app_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "flask-app-alb"

  load_balancer_type = "application"

  vpc_id          = module.flask_app_vpc.vpc_id
  subnets         = module.flask_app_vpc.public_subnets
  security_groups = [aws_security_group.flask_alb_sg.id]

  target_groups = [
    {
      name_prefix      = "app-"
      backend_protocol = "HTTP"
      backend_port     = 5000
      target_type      = "ip"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm_cert_request.acm_certificate_arn
      target_group_index = 0
    }
  ]
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  tags = {
    Terraform = "true"
  }
}