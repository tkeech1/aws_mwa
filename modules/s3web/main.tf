resource "aws_s3_bucket" "s3_static_web" {
  bucket        = "${var.bucket_name}-${var.environment}"
  force_destroy = true
  # Enable server-side encryption 
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_algorithm
      }
    }
  }

  acl    = "public-read"
  policy = data.aws_iam_policy_document.s3_web_policy.json

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    environment = var.environment
  }
}

