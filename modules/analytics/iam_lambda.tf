# create the IAM instance role for Lambda
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

/*
# Policy to give permissions to write records to the firehose endpoint
resource "aws_iam_role_policy" "firehose_policy" {
  name   = "firehose_policy"
  role   = "${aws_iam_role.lambda_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ],
      "Effect": "Allow",
      "Resource": 
        ["arn:aws:firehose:${var.region}:${data.aws_caller_identity.current.account_id}:deliverystream/${aws_kinesis_firehose_delivery_stream.PurchaseLogs_s3_firehose_stream.name}"]
    },
    { 
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Effect": "Allow",
      "Resource": "*"      
    }
  ]
}
EOF
}
*/

data "aws_caller_identity" "current" {}

# allows a lambda to log to CloudWatch
resource "aws_iam_policy" "analytics_logging_policy" {
  name        = "analytics_logging_policy"
  path        = "/"
  description = "IAM policy for logging from the analytics resources"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_cloudwatch_log_group.mwa_analytics_log.name}:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# attaches the logging policy to the lambda role
resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.analytics_logging_policy.arn
}
