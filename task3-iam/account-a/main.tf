locals {
  cli_users = ["engine", "ci"]
}

resource "aws_iam_user" "cli" {
  for_each = toset(local.cli_users)
  name     = each.value

  # No login profile. Programmatic only — and even then I am not minting access keys here.
  tags = {
    Access = "programmatic"
  }
}

resource "aws_iam_group" "group1" {
  name = "group1"
}

resource "aws_iam_group_membership" "group1" {
  name  = "group1-members"
  group = aws_iam_group.group1.name
  users = [for u in aws_iam_user.cli : u.name]
}

# Stop someone adding a console password later and calling it "still CLI".
resource "aws_iam_group_policy" "group1_no_console" {
  name  = "no-console-login"
  group = aws_iam_group.group1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "NoLoginProfile"
        Effect = "Deny"
        Action = [
          "iam:CreateLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:ChangePassword",
        ]
        Resource = "arn:aws:iam::${var.account_a_id}:user/$${aws:username}"
      }
    ]
  })
}

resource "aws_iam_user" "console" {
  for_each = toset(var.group2_users)
  name     = each.value

  tags = {
    Access = "console-and-cli"
  }
}

resource "aws_iam_group" "group2" {
  name = "group2"
}

resource "aws_iam_group_membership" "group2" {
  name  = "group2-members"
  group = aws_iam_group.group2.name
  users = [for u in aws_iam_user.console : u.name]
}

resource "aws_iam_group_policy_attachment" "group2_admin" {
  group      = aws_iam_group.group2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# roleA — admin except IAM. Deny wins over the allow, including if someone
# attaches a second policy later.
data "aws_iam_policy_document" "roleA_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [for u in aws_iam_user.console : u.arn]
    }
  }
}

resource "aws_iam_role" "roleA" {
  name               = "roleA"
  assume_role_policy = data.aws_iam_policy_document.roleA_trust.json
}

resource "aws_iam_role_policy" "roleA" {
  name = "admin-except-iam"
  role = aws_iam_role.roleA.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllServices"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Sid      = "NotIam"
        Effect   = "Deny"
        Action   = "iam:*"
        Resource = "*"
      }
    ]
  })
}

# roleB — the only thing it can do is assume roleC in Account B.
data "aws_iam_policy_document" "roleB_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [for u in aws_iam_user.console : u.arn]
    }
  }
}

resource "aws_iam_role" "roleB" {
  name               = "roleB"
  assume_role_policy = data.aws_iam_policy_document.roleB_trust.json
}

resource "aws_iam_role_policy" "roleB" {
  name = "assume-roleC"
  role = aws_iam_role.roleB.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AssumeRoleC"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::${var.account_b_id}:role/roleC"
      }
    ]
  })
}

# Task 4. Scoped to ci, not to the whole of group1 (engine doesn't deploy).
resource "aws_iam_policy" "ci_pipeline" {
  name        = "ci-pipeline"
  description = "Push one ECR repo, update one ECS service, read one artifact bucket."

  policy = templatefile("${path.module}/../../task4-ci-policy/ci-pipeline.json.tpl", {
    region          = var.region
    account_a_id    = var.account_a_id
    ecr_repo_name   = var.ecr_repo_name
    ecs_cluster     = var.ecs_cluster
    ecs_service     = var.ecs_service
    artifact_bucket = var.artifact_bucket
    exec_role_name  = var.ecs_execution_role_name
    task_role_name  = var.ecs_task_role_name
  })
}

resource "aws_iam_user_policy_attachment" "ci" {
  user       = aws_iam_user.cli["ci"].name
  policy_arn = aws_iam_policy.ci_pipeline.arn
}
