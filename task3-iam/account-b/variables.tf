variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_profile" {
  type        = string
  default     = ""
  description = "Profile for Account B. Empty uses AWS_PROFILE. Same as Account A if you only have one account."
}

variable "account_a_id" {
  type = string
}

variable "bucket_name" {
  type        = string
  default     = "your-unique-rolec-bucket-name"
  description = "Use a globally unique S3 bucket name."
}
