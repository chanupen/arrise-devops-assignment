variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_profile" {
  type        = string
  default     = ""
  description = "Named profile. Leave empty to use AWS_PROFILE / env credentials."
}

variable "bucket_name" {
  type        = string
  description = "Globally unique. Something like chandan-arrise-tfstate-<accountid>."
}

variable "lock_table" {
  type    = string
  default = "arrise-tflock"
}
