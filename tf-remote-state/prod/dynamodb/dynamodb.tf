terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_dynamodb_table" "terraform-locks-itsy-prod-us-west-2" {
  name         = "terraform-locks-itsy-prod-us-west-2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}