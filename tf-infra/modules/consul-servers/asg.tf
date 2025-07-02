module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "consul-servers"

  min_size                  = var.consul_server_min_size
  max_size                  = var.consul_server_max_size
  desired_capacity          = var.consul_server_desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.private_subnet_ids
  
  create_traffic_source_attachment = true
  traffic_source_identifier        = var.alb_server_target_groups["consul_target"].arn
  traffic_source_type              = "elbv2"

  initial_lifecycle_hooks = [
    {
      name                  = "ExampleStartupLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 60
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                  = "ExampleTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 70
    }
  }

  # Launch template
  launch_template_name        = "consul-servers-lt"
  launch_template_description = "Consul servers launch template"
  update_default_version      = true
  
  user_data = base64encode(templatefile("${path.module}/scripts/consul-server.tftpl.sh", {
    consul_acl_bootstrap_token = "hello",
    consul_server_cfg = templatefile("${path.module}/templates/consul-server.tftpl", {
      aws_region               = var.aws_region,
      consul_bootstrap_expect   = var.consul_bootstrap_expect,
      consul_join_tag_key       = var.consul_join_tag_key,
      consul_join_tag_value     = var.consul_join_tag_value,
    }),
  }))

  security_groups             = [var.ec2_security_group_id]

  image_id          = var.ami
  instance_type     = var.consul_server_instance_type
  ebs_optimized     = true
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = false
  iam_instance_profile_arn = aws_iam_instance_profile.instance_profile.arn

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
    }, {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    /* http_tokens                 = "required" */
    http_put_response_hop_limit = 32
    instance_metadata_tags      = "enabled"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { WhatAmI = "Instance" }
    },
    {
      resource_type = "instance"
      tags          = { consul-cluster = "consul-cluster" }
    },
    {
      resource_type = "volume"
      tags          = { WhatAmI = "Volume" }
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "megasecret"
    consul-cluster = "consul-servers"
    consul_ec2_join = var.consul_join_tag_value
  }
}