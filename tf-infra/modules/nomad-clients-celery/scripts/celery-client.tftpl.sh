#!/usr/bin/env bash

# Script to bootstrap Nomad as client node.

# This script performs the following tasks:
# - Prepares DNS configuration for exec tasks
# - Renders the Nomad client configuration
# - Optionally, adds Docker configuration to Nomad if the 'enable_docker_plugin' variable is set to true
# - Starts the Nomad service

set -Eeuo pipefail

declare -r SCRIPT_NAME="$(basename "$0")"
declare -ag AWS_TAGS=()

# Send the log output from this script to user-data.log, syslog, and the console.
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Wrapper to log any outputs from the script to stderr
function log {
  declare -r LVL="$1"
  declare -r MSG="$2"
  declare -r TS=$(date +"%Y-%m-%d %H:%M:%S")
  echo >&2 -e "$TS [$LVL] [$SCRIPT_NAME] $MSG"
}

# Stores AWS tags to use as nomad client meta
# Requires `nomad-cluster` tag to be defined
# within AWS instance tags
store_tags() {
  max_attempts=3
  count=0

  while true; do
    TOKEN=$(curl -s --connect-timeout 1 --retry 3 --retry-delay 3 \
      -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    TAGS=$(curl -s --connect-timeout 1 --retry 3 --retry-delay 3 \
      -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance)

    # If there's no 'nomad-cluster' found in tags, retry.
    if [[ "$TAGS" != *"nomad-cluster"* ]]; then
      sleep 1

      count=$((count + 1))

      # If max retries still didn't get the data, fail.
      if [[ $count -eq $max_attempts ]]; then
        log "ERROR" "aborting as max attempts reached"
        exit 1
      fi
      continue
    fi

    readarray -t AWS_TAGS <<<"$TAGS"
    break

  done
}

# Sets hostname for the system
# Replaces `ip` in the hostname with the AWS instance `Name` tag
set_hostname() {
  for t in "$${AWS_TAGS[@]}"; do
    # For servers we'll use the NAME tag of the EC2 instance.
    if [ "$t" == "Name" ]; then
      TAG=$(curl -s --retry 3 --retry-delay 3 --connect-timeout 3 \
        -H "Accept: application/json" -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/tags/instance/$t")

      # The original hostname is like `ip-10-x-y-z`
      CURR_HOSTNAME=$(sudo hostnamectl --static)
      # Replace `ip` with tag value.
      HOSTNAME="$${CURR_HOSTNAME//ip/$TAG}"
      log "INFO" "setting hostname as $HOSTNAME"
      sudo hostnamectl set-hostname "$HOSTNAME"
    fi
  done
}

# Ensures the resolv.conf within nomad `exec` jobs
# can access other machines
# see: https://github.com/hashicorp/nomad/issues/11033
prepare_dns_config() {
  cat <<EOF >/etc/nomad.d/route53_resolv.conf
nameserver ${route_53_resolver_address}
search ${aws_region}.compute.internal
EOF
}

prepare_ecr_config() {
    cat <<EOF >/etc/docker/config.json
{
    "credHelpers": {
      "${ecr_address}": "ecr-login"
    }
}
EOF
}

# Enables nomad systemd service
start_nomad() {
  sudo systemctl enable --now nomad
}

# Restarts nomad systemd service
restart_nomad() {
  sudo systemctl restart nomad
}

# Sets up `/etc/nomad.d`
prepare_nomad_client_config() {
  cat <<EOF >/etc/nomad.d/nomad.hcl
${nomad_client_cfg}
EOF
}

# enable consul systemd service
start_consul() {
  sudo systemctl enable --now consul
}

# restart consul systemd service
restart_consul() {
  sudo systemctl restart consul
}

# prepare consul config
prepare_consul_config() {
  cat <<EOF >/etc/consul.d/consul.hcl
${consul_client_cfg}
EOF
}


log "INFO" "Fetching EC2 Tags from AWS"
store_tags

log "INFO" "Setting machine hostname"
set_hostname

log "INFO" "Preparing ECR config"
prepare_ecr_config

log "INFO" "Prepare DNS config for exec tasks"
prepare_dns_config

log "INFO" "Rendering client config for nomad"
prepare_nomad_client_config

log "INFO" "Starting Nomad service"
start_nomad

log "INFO" "Finished client initializing process! Enjoy Nomad!"

log "INFO" "Rendering consul config for Nomad"
prepare_consul_config

log "INFO" "Starting Consul service"
start_consul

log "INFO" "Restarting services"
restart_consul

log "INFO" "Finished server initializing processes! Enjoy Consul!"