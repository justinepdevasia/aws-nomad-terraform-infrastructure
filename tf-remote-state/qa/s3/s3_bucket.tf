terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "terraform-state-itsy-qa-us-west-1" {
  bucket = "terraform-state-itsy-qa-us-west-1"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}