data "aws_iam_policy_document" "s3_web_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${var.bucket_name}-${var.environment}/*"
    ]
  }
}
