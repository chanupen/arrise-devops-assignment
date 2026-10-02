variable "instances" {
  type = map(object({
    instance_type    = string
    root_volume_type = string
    root_volume_size = number
    root_iops        = optional(number)
    key_name         = string
    protect          = optional(bool, false)
  }))

  validation {
    condition     = length([for _, cfg in var.instances : cfg if cfg.protect]) == 1
    error_message = "Mark exactly one instance with protect = true."
  }
}

variable "ami_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}
