resource "aws_cloudwatch_log_group" "mwa_analytics_log" {
  name              = "mwa_analytics_log"
  retention_in_days = 1
}

# create a lambda
resource "aws_lambda_function" "kinesis_firehose_processor" {
  filename      = "stream_processor_lambda.zip"
  function_name = "kinesis_firehose_processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "streamProcessor.processRecord"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("stream_processor_lambda.zip")

  runtime    = "python3.7"
  depends_on = [aws_iam_role_policy_attachment.lambda_logging_policy_attachment, aws_cloudwatch_log_group.mwa_analytics_log]

  environment {
    variables = {
      "api_endpoint" = var.api_endpoint
    }
  }

  tags = {
    environment = var.environment
  }
}
