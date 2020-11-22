

// create a cognito user pool
module "mwa_cognito" {
  source      = "./modules/cognito"
  environment = "mwa"
}

/* mwa application */
module "mwa" {
  source               = "./modules/infrastructure"
  environment          = "mwa"
  region               = var.region
  cognito_user_pool_id = module.mwa_cognito.cognito_user_pool_id
}

// create an ecr registry
module "mwa_ecr" {
  source      = "./modules/ecr"
  environment = "mwa"
}

// create a dynamodb table
module "mwa_dynamodb" {
  source      = "./modules/dynamodb"
  environment = "mwa"
}

// create the static web frontend
module "mwa_s3web" {
  source        = "./modules/s3web"
  environment   = var.environment
  bucket_name   = var.s3_web_bucket_name
  sse_algorithm = var.sse_algorithm
}

// create the ecs cluster
module "mwa_ecs" {
  source                = "./modules/ecs"
  ecs_role_arn          = module.mwa.mwa_ecs_role_arn
  ecs_task_role_arn     = module.mwa.mwa_ecs_task_role_arn
  ecr_image_tag         = "${module.mwa_ecr.ecr_repository_url}:latest"
  security_group_id     = module.mwa.mwa_security_group_id
  private_subnet_one_id = module.mwa.mwa_private_subnet_one_id
  private_subnet_two_id = module.mwa.mwa_private_subnet_two_id
  target_group_arn      = module.mwa.mwa_target_group_arn
  environment           = "mwa"
}

module "mwa_analytics" {
  source       = "./modules/analytics"
  api_endpoint = module.mwa.mwa_api_endpoint
  environment  = "mwa"
  region       = var.region
}

module "mwa_s3deploy" {
  source                      = "./modules/s3deploy"
  cognito_user_pool_id        = module.mwa_cognito.cognito_user_pool_id
  cognito_user_pool_client_id = module.mwa_cognito.cognito_user_pool_client_id
  region                      = var.region
  api_endpoint                = module.mwa.mwa_api_endpoint
  website_endpoint            = module.mwa_s3web.mwa_website_endpoint
  depends_on                  = [module.mwa]
}
