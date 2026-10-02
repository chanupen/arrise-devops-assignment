output "roleA_arn" {
  value = aws_iam_role.roleA.arn
}

output "roleB_arn" {
  value = aws_iam_role.roleB.arn
}

output "ci_policy_arn" {
  value = aws_iam_policy.ci_pipeline.arn
}
