resource "aws_ecr_repository" "flask_ecr_repo" {
  name                 = "flask-app-ecr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}