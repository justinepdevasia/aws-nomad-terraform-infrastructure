###################   Elastic Cache subnet group    #######################

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.subnet_name}-${var.environment}"
  subnet_ids = var.subnet_ids
}

###################   Elastic Cache Cluster    #######################


locals {
  name      = ["celery", "authentication"]
  node_type = (var.node_type != "" ? var.node_type : "cache.t3.micro")
}



resource "aws_elasticache_cluster" "test" {
  count             = 2
  cluster_id        = "${var.cluster_id}-${var.environment}-${element(local.name, count.index)}"
  engine            = "redis"
  node_type         = local.node_type
  num_cache_nodes   = var.nodes
  subnet_group_name = aws_elasticache_subnet_group.redis.name
  port              = 6379
  apply_immediately = true
  log_delivery_configuration {
    destination      = "log_group"
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = var.log_type
  }
  depends_on = [
    aws_elasticache_subnet_group.redis
  ]

  security_group_ids   = [aws_security_group.redis_security_group.id]
  tags = {
    env = var.environment
    service = element(local.name, count.index)
  }
}

################################################
resource "aws_security_group" "redis_security_group" {
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.redis_security_group_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["172.0.0.0/8"]
      #  ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-redis-sg"
    Environment = "${var.environment}"
  }
}