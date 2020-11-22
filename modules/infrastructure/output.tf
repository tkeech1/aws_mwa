output "mwa_ecs_role_arn" {
  value = aws_iam_role.mwa_ecs_role.arn
}

output "mwa_ecs_task_role_arn" {
  value = aws_iam_role.mwa_ecs_task_role.arn
}

output "mwa_security_group_id" {
  value = aws_default_security_group.mwa_security_group.id
}

output "mwa_private_subnet_one_id" {
  value = aws_subnet.private_subnet_one.id
}

output "mwa_public_subnet_two_id" {
  value = aws_subnet.public_subnet_two.id
}

output "mwa_public_subnet_one_id" {
  value = aws_subnet.public_subnet_one.id
}

output "mwa_private_subnet_two_id" {
  value = aws_subnet.private_subnet_two.id
}

output "mwa_target_group_arn" {
  value = aws_lb_target_group.mwa_nlb_target_group.arn
}

output "mwa_api_endpoint" {
  value = aws_api_gateway_deployment.mwa_api_gateway_deployment.invoke_url
}
