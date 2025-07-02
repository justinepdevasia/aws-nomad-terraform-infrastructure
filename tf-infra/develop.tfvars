region                  = "us-west-2"
environment             = "dev"
alb_certificate_arn     = "arn:aws:acm:us-west-2:786731984788:certificate/1bee4134-c0e6-49cf-a29f-d755843a3b86"
client_host_adress_list = ["stage.api.itsy.dev", "stage.itsy.dev"]
nomad_host_name         = "nomad.develop.itsy.dev"
consul_host_name        = "consul.develop.itsy.dev"
ami                     = "ami-0f2ab35e75ec8c4fe"
ecr_address             = "786731984788.dkr.ecr.us-west-2.amazonaws.com"
image_mutability        = "MUTABLE"
ecr_name = [
  "itsy/ts-backend",
  "itsy/ts-authentication",
  "itsy/ts-engine",
]
alb_domain_certificate_arns = [
  "arn:aws:acm:us-west-2:786731984788:certificate/f74eb27e-0f57-4e95-b61d-2db7de507ef8",
  "arn:aws:acm:us-west-2:786731984788:certificate/eaa4645e-c6a0-4e92-aa0e-f83ac6a07b0f"
]


nomad_server_min_size         = "1"
nomad_server_max_size         = "1"
nomad_server_desired_capacity = "1"

consul_server_min_size         = "1"
consul_server_max_size         = "1"
consul_server_desired_capacity = "1"

nomad_client_apm_min_size         = "1"
nomad_client_apm_max_size         = "1"
nomad_client_apm_desired_capacity = "1"

nomad_client_django_min_size         = "2"
nomad_client_django_max_size         = "2"
nomad_client_django_desired_capacity = "2"

nomad_client_elixir_min_size         = "1"
nomad_client_elixir_max_size         = "1"
nomad_client_elixir_desired_capacity = "1"

nomad_client_traefik_min_size         = "1"
nomad_client_traefik_max_size         = "1"
nomad_client_traefik_desired_capacity = "1"

nomad_client_rabbit_min_size         = "1"
nomad_client_rabbit_max_size         = "1"
nomad_client_rabbit_desired_capacity = "1"

nomad_client_celery_min_size         = "1"
nomad_client_celery_max_size         = "1"
nomad_client_celery_desired_capacity = "1"

nomad_client_datastore_min_size         = "2"
nomad_client_datastore_max_size         = "2"
nomad_client_datastore_desired_capacity = "2"

itsy_media_bucket = "itsy-media-bucket-dev"
itsy_web_bucket   = "itsy-web-bucket-dev"

django_static_public_prefix = "static/ts-backend/public"
elixir_static_public_prefix = "static/ts-engine/public"
django_media_public_prefix  = "media/ts-backend/public"
elixir_media_public_prefix  = "media/ts-engine/public"

consul_server_instance_type = "t3.micro"
nomad_server_instance_type  = "t3.micro"

nomad_client_apm_instance_type       = "t3a.small"
nomad_client_django_instance_type    = "t3a.small"
nomad_client_elixir_instance_type    = "t3.micro"
nomad_client_traefik_instance_type   = "t3.micro"
nomad_client_rabbit_instance_type    = "t3.micro"
nomad_client_celery_instance_type    = "t3a.small"
nomad_client_datastore_instance_type = "t3.micro"