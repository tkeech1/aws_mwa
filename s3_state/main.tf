provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket        = "${var.bucket_name}-${var.environment}"
  force_destroy = true
  # Enable versioning to see the full revision history of state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption 
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_algorithm
      }
    }
  }
  tags = {
    environment = var.environment
  }
}

# block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_bucket_policy" {
  bucket                  = aws_s3_bucket.terraform_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# TODO - encryption
resource "aws_dynamodb_table" "terraform_locks_dynamobdb" {
  name         = "${var.dynamodb_table_name}-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    environment = var.environment
  }
}
