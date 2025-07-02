resource "aws_security_group" "client_alb_security_group" {
  name   = "clients-alb-security-group"
  vpc_id = var.vpc_id

  # Nomad
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "server_alb_security_group" {
  name   = "servers-alb-security-group"
  vpc_id = var.vpc_id

  # Nomad
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_security_group" {
  name   = "ec2-security-group"
  vpc_id = var.vpc_id

  # Nomad
  # allow traffic from the ALB security group
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.client_alb_security_group.id]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    security_groups = [aws_security_group.server_alb_security_group.id]
  }
  
  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    security_groups = [aws_security_group.server_alb_security_group.id]
  }

  # allow all traffic within the security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "postgres_security_group" {
  name   = "itsy-postgres-security-group"
  vpc_id = var.vpc_id

  # Nomad
  # allow traffic from the ALB security group
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}