resource "aws_ecr_repository" "ecr_repo" {
  for_each             = toset(var.ecr_name)
  name                 = each.key
  image_tag_mutability = var.image_mutability

  image_scanning_configuration {
    scan_on_push = true
  } 
  //   encryption_configuration {
  //     encryption_type = var.encrypt_type
  //   }
}