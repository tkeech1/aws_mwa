output "state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state_bucket.arn
  description = "ARN of the S3 bucket"
}
output "state_bucket_id" {
  value       = aws_s3_bucket.terraform_state_bucket.id
  description = "ID of the S3 bucket"
}
