# Bucket roleC is allowed to touch. Policy does not need the bucket to exist,
# but then "full access to a named bucket" is a string with nothing behind it.
resource "aws_s3_bucket" "rolec" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "rolec" {
  bucket                  = aws_s3_bucket.rolec.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rolec" {
  bucket = aws_s3_bucket.rolec.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Task 5 fix, trust side.
# Broken snippet had arn:aws:iam::000000000000:user/roleB.
# roleB is a role. Caller principal on AssumeRole is the role ARN, not a user path.
data "aws_iam_policy_document" "roleC_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:role/roleB"]
    }
  }
}

resource "aws_iam_role" "roleC" {
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
}

# Task 5 fix, permissions side.
# Broken snippet had s3:* on Resource "*". That is every bucket in the account.
# Full access to one bucket still needs both ARNs: bucket ARN for bucket ops,
# bucket/* for object ops. One resource string is not enough.
resource "aws_iam_role_policy" "roleC_s3" {
  name = "roleC-s3-access"
  role = aws_iam_role.roleC.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "OneBucket"
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = [aws_s3_bucket.rolec.arn, "${aws_s3_bucket.rolec.arn}/*"]
      }
    ]
  })
}
