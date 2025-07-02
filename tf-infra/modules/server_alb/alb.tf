module "alb" {

  source  = "terraform-aws-modules/alb/aws"
  
  name = "server-alb"
  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = [var.server_alb_security_group_id]

  /* access_logs = {
    bucket = ""
  } */

  target_groups = {
    nomad_target = {
      name_prefix      = "nomad-"
      protocol = "HTTP"
      port     = 4646
      target_type      = "instance"
      create_attachment = false
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/ui/"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200"
      }
    }

    consul_target = {
      name_prefix      = "consul"
      protocol = "HTTP"
      port     = 8500
      target_type      = "instance"
      create_attachment = false
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/ui/"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  }

  listeners = {
    ex-https = {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.alb_certificate_arn

      forward = {
        target_group_key = "nomad_target"
      }

      rules = {
        rule-1 = {
          actions = [{
            type               = "forward"
            target_group_key   = "nomad_target"
          }]

          conditions = [{
            host_header = {
              values = ["${var.nomad_address}"]
            }
          }]
          
        }
        rule-2 = {
          actions = [{
            type               = "forward"
            target_group_key   = "consul_target"
          }]

          conditions = [{
            host_header = {
              values = ["${var.consul_address}"]
            }
          }]
        }
      }
    }
  }
}