resource "aws_cognito_user_pool" "mwa_user_pool" {
  name                     = "MysfitsUserPool"
  auto_verified_attributes = ["email"]

  tags = {
    environment = var.environment
  }
}

resource "aws_cognito_user_pool_client" "mwa_user_pool_client" {
  name = "MysfitsUserPoolClient"

  user_pool_id = aws_cognito_user_pool.mwa_user_pool.id
}
