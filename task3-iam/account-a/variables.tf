variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_profile" {
  type        = string
  default     = ""
  description = "Profile for Account A. Empty uses AWS_PROFILE / env credentials."
}

variable "account_a_id" {
  type        = string
  description = "Account A. Assignment uses 000000000000 — put your real id here before apply."
}

variable "account_b_id" {
  type        = string
  description = "Account B, where roleC lives."
}

variable "group2_users" {
  type        = list(string)
  default     = ["abhay.singh", "neha.gupta"]
  description = "Console + CLI. Rename if you want, keep it to two."
}

variable "ecr_repo_name" {
  type    = string
  default = "arrise/app"
}

variable "ecs_cluster" {
  type    = string
  default = "arrise"
}

variable "ecs_service" {
  type    = string
  default = "arrise-api"
}

variable "artifact_bucket" {
  type    = string
  default = "arrise-build-artifacts"
}

variable "ecs_execution_role_name" {
  type    = string
  default = "arrise-ecs-exec"
}

variable "ecs_task_role_name" {
  type    = string
  default = "arrise-ecs-task"
}
