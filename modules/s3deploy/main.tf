resource "null_resource" "frontend_var_replacement" {
  provisioner "local-exec" {
    command = "python ./modules/s3deploy/jinja2_templates/frontend_jinja.py --api-endpoint=${var.api_endpoint} --cognito-user-pool-id=${var.cognito_user_pool_id} --cognito-user-pool-client-id=${var.cognito_user_pool_client_id} --region=${var.region}"
  }
}

resource "null_resource" "print_web_endpoint" {
  provisioner "local-exec" {
    command = "echo ${var.website_endpoint} > web_url.txt"
  }
}
