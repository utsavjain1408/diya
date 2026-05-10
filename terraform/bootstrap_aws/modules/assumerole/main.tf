# IAM policy document allowing role assumption
data "aws_iam_policy_document" "assumerole" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity"
    ]
    principals {
      type        = "AWS"
      identifiers = ["${var.SharedAccountARN}"]
    }
  }
}

# IAM policy enabling AWS resource creation and deletion for Terraform state
data "aws_iam_policy_document" "tfbootstrap" {
  statement {
    # https://docs.aws.amazon.com/servicecatalog/latest/adminguide/getstarted-launchrole-Terraform.html
    actions   = [
      "s3:CreateBucket*",
      "s3:DeleteBucket*",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:DeletePublicAccessBlock",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "s3:PutBucketVersioning",  
      "s3:PutBucketTagging",     
      "s3:PutBucketPolicy"       
    ]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    actions   = [
      "iam:CreateOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:CreateRole",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = ["arn:aws:iam::${var.TargetAccount}:*"]
  }
}

resource "aws_iam_role" "assumerole" {
  name                = format("%s%s%s%s", var.Prefix, "iar", var.Environment, "tfassumerole")
  description         = "This role can be assumed to setup tfboot components from a single primary account"
  assume_role_policy  = data.aws_iam_policy_document.assumerole.json

  tags = {
    Name  = format("%s%s%s%s", var.Prefix, "iar", var.Environment, "tfassumerole")
    rtype = "security"
  }
}

resource "aws_iam_role_policy" "tfassumerole" {
  name   = format("%s%s%s%s", var.Prefix, "iap", var.Environment, "tfassumerole")
  role   = aws_iam_role.assumerole.id
  policy = data.aws_iam_policy_document.tfbootstrap.json
}

output "role_arn" {
  value = aws_iam_role.assumerole.arn
}