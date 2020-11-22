# TODO - lock down
data "aws_iam_policy_document" "vpc_endpoint_dynamodb" {
  statement {
    actions = [
      "*"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "*"
    ]
  }
}

# create the IAM instance role for ECS
resource "aws_iam_role" "mwa_ecs_role" {
  name               = "mwa_ecs_role"
  description        = "authorizes ECS to manage resources on the account, such as updating the load balancer with the details of where the containers are so that traffic can reach containers."
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
         "Effect":"Allow",
         "Principal":{
            "Service": ["ecs.amazonaws.com","ecs-tasks.amazonaws.com"]
         },
         "Action":"sts:AssumeRole"
        }
    ]
}
EOF

  tags = {
    environment = var.environment
  }
}

resource "aws_iam_role_policy" "ecs_policy" {
  name   = "ecs_policy"
  role   = aws_iam_role.mwa_ecs_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteNetworkInterfacePermission",
                "ec2:Describe*",
                "ec2:DetachNetworkInterface",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:RegisterTargets",
                "iam:PassRole",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:DescribeLogStreams",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"                
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# create the IAM instance role for ECS tasks
resource "aws_iam_role" "mwa_ecs_task_role" {
  name               = "mwa_ecs_task_role"
  description        = "authorizes ECS tasks to manage resources on the account. if containers access AWS services, add those permissions here."
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
         "Effect":"Allow",
         "Principal":{
            "Service": ["ecs-tasks.amazonaws.com"]
         },
         "Action":"sts:AssumeRole"
        }
    ]
}
EOF

  tags = {
    environment = var.environment
  }
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name   = "ecs_task_policy"
  role   = aws_iam_role.mwa_ecs_task_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"                
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:GetItem"               
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/MysfitsTable*"
        }
    ]
}
EOF
}

// create a service-linked role for ecs to allow it to make ecs API requests
// if the role has already been created in the account, no need to recreate
#resource "aws_iam_service_linked_role" "mwa_service_role_ecs" {
#  aws_service_name = "ecs.amazonaws.com"
#}
