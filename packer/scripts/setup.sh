#!/usr/bin/env bash

set -e

# Disable interactive apt prompts
export DEBIAN_FRONTEND=noninteractive

INSTALL_DOCKER="${INSTALL_DOCKER:-true}"
NOMAD_VERSION="${NOMAD_VERSION:-1.6.3}"
CONSUL_VERSION="${CONSUL_VERSION:-1.16.0}"
CONSUL_TEMPLATE_VERSION="${CONSUL_TEMPLATE_VERSION:-0.32.0}"
VAULT_VERSION="${VAULT_VERSION:-1.14.0}"
CNI_VERSION="${CNI_VERSION:-v1.3.0}"

# Update packages
sudo apt-get -y update
# Install software-properties-common
sudo apt-get install -y software-properties-common

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# Update packages again
sudo apt-get -y update

# Install Nomad
sudo apt-get install -y nomad="${NOMAD_VERSION}"-1
# Install Consul
sudo apt-get install -y consul="${CONSUL_VERSION}"-1
# Install Consul Template
sudo apt-get install -y consul-template="${CONSUL_TEMPLATE_VERSION}"-1
# Install Vault
sudo apt-get install -y vault="${VAULT_VERSION}"-1


# Disable the firewall
sudo ufw disable || echo "ufw not installed"


# Install Docker if INSTALL_DOCKER is true
if [ "$INSTALL_DOCKER" = true ]; then
  sudo apt-get -y update
  sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get -y update
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  
  # Create daemon.json if it doesn't exist
  if [ ! -f /etc/docker/daemon.json ]; then
    sudo touch /etc/docker/daemon.json
  fi

  # Restart Docker
  sudo systemctl restart docker
  sudo usermod -aG docker ubuntu

fi

# Download and install CNI plugins
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-$([ "$(uname -m)" = aarch64 ] && echo arm64 || echo amd64)-${CNI_VERSION}".tgz &&
  sudo mkdir -p /opt/cni/bin &&
  sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

# install aws cli
sudo apt-get install awscli -y

# install ecr credentials in linux for pulling images from docker
sudo wget  https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.6.0/linux-amd64/docker-credential-ecr-login
sudo chmod +x docker-credential-ecr-login
sudo cp docker-credential-ecr-login  ecr-login
sudo mv docker-credential-ecr-login  ecr-login /usr/bin

# Setup Systemd
sudo apt-get install -y net-tools

# add consul config to systemd
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/consul.conf
[Resolve]
DNS=127.0.0.1:8600
DNSSEC=false
Domains=~consul
EOF

sudo cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/docker.conf
[Resolve]
DNSStubListener=yes
DNSStubListenerExtra=172.17.0.1
EOF

# test 
sudo systemctl restart systemd-resolved
sudo resolvectl domain

# Done