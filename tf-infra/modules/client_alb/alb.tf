module "alb" {

  source  = "terraform-aws-modules/alb/aws"
  
  name = "client-alb"
  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = [var.client_alb_security_group_id]

  /* access_logs = {
    bucket = ""
  } */

  target_groups = {
    ex-instance = {
      name_prefix      = "front-"
      protocol = "HTTP"
      port     = 80
      target_type      = "instance"
      create_attachment = false
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/ping"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  }

  #####
  listeners = {
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.alb_certificate_arn
      additional_certificate_arns = var.alb_domain_certificate_arns

      forward = {
        target_group_key = "ex-instance"
      }

      rules = {
        ex-https-rules = {
          actions = [
            {
              type               = "forward"
              target_group_key = "ex-instance"
            }
          ]

          conditions = [{
            host_header = {
              values = var.host_address_list
            }
          }]

        }
        
      }
    }
  }

  tags = {
    Name = "nomad_client_alb"
  }
}