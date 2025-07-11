region                  = "us-west-2"
environment             = "prod"
alb_certificate_arn     = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"
client_host_adress_list = ["api.app.dev", "app.dev"]
nomad_host_name         = "nomad.app.dev"
consul_host_name        = "consul.app.dev"
ami                     = "ami-xxxxxxxxx"
ecr_address             = "123456789012.dkr.ecr.us-west-2.amazonaws.com"
image_mutability        = "MUTABLE"
ecr_name = [
  "app/ts-backend",
  "app/ts-authentication",
  "app/ts-engine",
]
alb_domain_certificate_arns = [
  "arn:aws:acm:us-west-2:123456789012:certificate/87654321-4321-4321-4321-210987654321",
  "arn:aws:acm:us-west-2:123456789012:certificate/abcdef12-3456-7890-abcd-ef1234567890"
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

nomad_client_django_min_size         = "1"
nomad_client_django_max_size         = "1"
nomad_client_django_desired_capacity = "1"

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

nomad_client_datastore_min_size         = "1"
nomad_client_datastore_max_size         = "1"
nomad_client_datastore_desired_capacity = "1"

media_bucket = "app-media-bucket-prod"
web_bucket   = "app-web-bucket-prod"

django_static_public_prefix = "static/ts-backend/public"
elixir_static_public_prefix = "static/ts-engine/public"
django_media_public_prefix  = "media/ts-backend/public"
elixir_media_public_prefix  = "media/ts-engine/public"

consul_server_instance_type = "t3.micro"
nomad_server_instance_type  = "t3.micro"

nomad_client_apm_instance_type       = "t3.micro"
nomad_client_django_instance_type    = "t3.micro"
nomad_client_elixir_instance_type    = "t3.micro"
nomad_client_traefik_instance_type   = "t3.micro"
nomad_client_rabbit_instance_type    = "t3.micro"
nomad_client_celery_instance_type    = "t3a.small"
nomad_client_datastore_instance_type = "t3.micro"