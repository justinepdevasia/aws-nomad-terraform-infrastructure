packer {
  required_version = ">= 1.9.0"
}


locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 
  ami_prefix = "nomad-${var.nomad_version}"
}

data "amazon-ami" "nomad_consul_ami" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = var.ami_name
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region = var.aws_region
}


source "amazon-ebs" "nomad_consul_ami" {
  ami_description = "AMI for Nomad agents based on Ubuntu"
  ami_name      = "${local.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  shutdown_behavior     = "terminate"
  force_deregister      = true
  force_delete_snapshot = true
  tags = {
    nomad_version   = var.nomad_version
    source_ami_id   = "{{ .SourceAMI }}"
    source_ami_name = "{{ .SourceAMIName }}"
    Name            = "${local.ami_prefix}"
  }

  region        = var.aws_region
  source_ami    = "${data.amazon-ami.nomad_consul_ami.id}"
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.nomad_consul_ami"]

  provisioner "shell" {
    inline = ["sleep 10"]
  }

  provisioner "shell" {
    environment_vars = ["NOMAD_VERSION=${var.nomad_version}", "CONSUL_VERSION=${var.consul_version}", "VAULT_VERSION=${var.vault_version}", "CONSUL_TEMPLATE_VERSION=${var.consul_template_version}"]
    script = "./scripts/setup.sh"
  }

}