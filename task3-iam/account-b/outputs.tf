output "roleC_arn" {
  value = aws_iam_role.roleC.arn
}

output "bucket" {
  value = aws_s3_bucket.rolec.bucket
}
