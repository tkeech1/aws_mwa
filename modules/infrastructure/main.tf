resource "aws_vpc" "mwa_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    environment = var.environment
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.mwa_vpc.default_network_acl_id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "108.16.31.89/32"
    from_port  = 22
    to_port    = 22
  }

  # AWS systems manager
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "18.206.107.24/29"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 800
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8080
    to_port    = 8080
  }

  # allow https return traffic from http requests
  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 700
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = -1
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

}

resource "aws_default_security_group" "mwa_security_group" {
  vpc_id = aws_vpc.mwa_vpc.id

  /*ingress {
    description = "SSH from Local and EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["108.16.31.89/32", "18.206.107.24/29"]
  }*/

  /*ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["108.16.31.89/32"]
  }*/

  /*ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }*/

  ingress {
    description = "allow all inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    environment = var.environment
  }
}

// Create subnets in different AZs
resource "aws_subnet" "public_subnet_one" {
  vpc_id                  = aws_vpc.mwa_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1f"
  map_public_ip_on_launch = true

  tags = {
    environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_two" {
  vpc_id                  = aws_vpc.mwa_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_one" {
  vpc_id                  = aws_vpc.mwa_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1f"
  map_public_ip_on_launch = false

  tags = {
    environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_two" {
  vpc_id                  = aws_vpc.mwa_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = {
    environment = var.environment
  }
}

// Create Internet Gateway, route table and attach them to the public subnet
resource "aws_internet_gateway" "mwa_internet_gateway" {
  vpc_id = aws_vpc.mwa_vpc.id

  tags = {
    environment = var.environment
  }
}

resource "aws_route_table" "mwa_ig_route_table" {
  vpc_id = aws_vpc.mwa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mwa_internet_gateway.id
  }

  tags = {
    environment = var.environment
  }
}

resource "aws_route_table_association" "mwa_ra_public_subnet_one" {
  subnet_id      = aws_subnet.public_subnet_one.id
  route_table_id = aws_route_table.mwa_ig_route_table.id
}

resource "aws_route_table_association" "mwa_ra_public_subnet_two" {
  subnet_id      = aws_subnet.public_subnet_two.id
  route_table_id = aws_route_table.mwa_ig_route_table.id
}

// Create NAT Gateways, route tables and attach them to the PUBLIC subnet
resource "aws_eip" "mwa_eip_private_subnet_one_natgw" {
  vpc = true
  tags = {
    environment = var.environment
  }
}

resource "aws_eip" "mwa_eip_private_subnet_two_natgw" {
  vpc = true
  tags = {
    environment = var.environment
  }
}

resource "aws_nat_gateway" "private_subnet_one_natgw" {
  allocation_id = aws_eip.mwa_eip_private_subnet_one_natgw.id
  subnet_id     = aws_subnet.public_subnet_one.id
  tags = {
    environment = var.environment
  }
}

resource "aws_nat_gateway" "private_subnet_two_natgw" {
  allocation_id = aws_eip.mwa_eip_private_subnet_two_natgw.id
  subnet_id     = aws_subnet.public_subnet_two.id
  tags = {
    environment = var.environment
  }
}

resource "aws_route_table" "mwa_private_subnet_one_route_table" {
  vpc_id = aws_vpc.mwa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.private_subnet_one_natgw.id
  }

  tags = {
    environment = var.environment
  }
}

resource "aws_route_table" "mwa_private_subnet_two_route_table" {
  vpc_id = aws_vpc.mwa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.private_subnet_two_natgw.id
  }

  tags = {
    environment = var.environment
  }
}

resource "aws_route_table_association" "mwa_ra_private_subnet_one" {
  subnet_id      = aws_subnet.private_subnet_one.id
  route_table_id = aws_route_table.mwa_private_subnet_one_route_table.id
}

resource "aws_route_table_association" "mwa_ra_private_subnet_two" {
  subnet_id      = aws_subnet.private_subnet_two.id
  route_table_id = aws_route_table.mwa_private_subnet_two_route_table.id
}

// create a vpc endpoint for dynamodb for the private subnets
resource "aws_vpc_endpoint" "mwa_dynamodb_vpc_endpoint" {
  vpc_id            = aws_vpc.mwa_vpc.id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  policy            = data.aws_iam_policy_document.vpc_endpoint_dynamodb.json

  route_table_ids = [aws_route_table.mwa_private_subnet_one_route_table.id, aws_route_table.mwa_private_subnet_two_route_table.id]
  tags = {
    environment = var.environment
  }
}

// create an network load balancer
resource "aws_lb" "mwa_nlb" {
  name                       = "mwa-nlb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = [aws_subnet.private_subnet_one.id, aws_subnet.private_subnet_two.id]
  enable_deletion_protection = false

  tags = {
    environment = var.environment
  }
}

// create a load balancer target group
resource "aws_lb_target_group" "mwa_nlb_target_group" {
  name        = "mwa-nlb-target-group"
  port        = 8080
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.mwa_vpc.id
  health_check {
    interval            = 10
    path                = "/"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    environment = var.environment
  }
}

// create a network load balancer listener
resource "aws_lb_listener" "mwa_nlb_front_end" {
  load_balancer_arn = aws_lb.mwa_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mwa_nlb_target_group.arn
  }
}

resource "aws_api_gateway_vpc_link" "mwa_api_gateway" {
  name        = "mwa_api_gateway"
  description = "API Gateway frontend for NLB"
  target_arns = [aws_lb.mwa_nlb.arn]
  tags = {
    environment = var.environment
  }
}

data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "mwa_rest_api" {
  name        = "mwa_rest_api"
  description = "This is my API for demonstration purposes"
  body        = templatefile("./modules/infrastructure/api-swagger.json", { region = var.region, account_id = data.aws_caller_identity.current.account_id, cognito_user_pool_id = var.cognito_user_pool_id, vpc_link_id = aws_api_gateway_vpc_link.mwa_api_gateway.id, nlb_dns_name = aws_lb.mwa_nlb.dns_name })

  tags = {
    environment = var.environment
  }
}

resource "aws_api_gateway_deployment" "mwa_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.mwa_rest_api.id
  stage_name  = var.environment

  lifecycle {
    create_before_destroy = true
  }

}
