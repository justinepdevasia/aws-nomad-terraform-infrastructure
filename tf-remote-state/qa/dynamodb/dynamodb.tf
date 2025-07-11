terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_dynamodb_table" "terraform-locks-app-qa-us-west-1" {
  name         = "terraform-locks-app-qa-us-west-1"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}