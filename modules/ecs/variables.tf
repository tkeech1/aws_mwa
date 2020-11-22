variable "environment" {
  type = string
}

variable "ecs_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecr_image_tag" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "private_subnet_one_id" {
  type = string
}

variable "private_subnet_two_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

