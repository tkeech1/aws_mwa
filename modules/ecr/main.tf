
resource "aws_ecr_repository" "mwa_ecr_repo" {
  name                 = "mwa_ecr_repo/service"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    environment = var.environment
  }
}