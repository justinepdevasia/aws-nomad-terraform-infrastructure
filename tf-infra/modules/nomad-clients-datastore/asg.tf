module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "nomad-clients-datastore"

  min_size                  = var.nomad_client_datastore_min_size
  max_size                  = var.nomad_client_datastore_max_size
  desired_capacity          = var.nomad_client_datastore_desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.private_subnet_ids

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
  launch_template_name        = "nomad-client-datastore-lt"
  launch_template_description = "Nomad client datastore launch template"
  update_default_version      = true
  
  user_data = base64encode(templatefile("${path.module}/scripts/datastore-client.tftpl.sh", {
    route_53_resolver_address = var.route_53_resolver_address, 
    ecr_address               = var.ecr_address,
    aws_region               = var.aws_region,
    nomad_client_cfg = templatefile("${path.module}/templates/datastore-client.tftpl", {
      nomad_dc                 = var.nomad_dc,
      aws_region               = var.aws_region,
      nomad_join_tag_key       = var.nomad_join_tag_key,
      nomad_join_tag_value     = var.nomad_join_tag_value,
      node_class                = var.node_class,
    }),
    consul_client_cfg = templatefile("${path.module}/templates/consul-client.tftpl", {
      aws_region               = var.aws_region,
      consul_join_tag_key       = var.consul_join_tag_key,
      consul_join_tag_value     = var.consul_join_tag_value,
    }),
  }))


  security_groups             = [var.ec2_security_group_id]

  image_id          = var.ami
  instance_type     = var.nomad_client_datastore_instance_type
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
      tags          = { nomad-cluster = "nomad-cluster" }
    },
    {
      resource_type = "volume"
      tags          = { WhatAmI = "Volume" }
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "megasecret"
    nomad-cluster = "nomad-clients-datastore"
    nomad_ec2_join = var.nomad_join_tag_value
  }

}