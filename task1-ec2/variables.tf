variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_profile" {
  type        = string
  default     = ""
  description = "Named profile. Leave empty to use the ambient AWS_PROFILE / env credentials."
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "owner" {
  type    = string
  default = "chandan.kumar"
}

variable "vpc_cidr" {
  type    = string
  default = "10.42.0.0/16"
}

# Single input for all five boxes. protect = true is filtered onto its own
# resource so prevent_destroy can be a literal (terraform won't take a var there).
variable "instances" {
  description = "Map of instance name -> shape. Exactly one entry should have protect = true."
  type = map(object({
    instance_type    = string
    root_volume_type = string
    root_volume_size = number
    root_iops        = optional(number)
    key_name         = string
    protect          = optional(bool, false)
  }))
}
