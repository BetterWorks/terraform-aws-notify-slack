locals {
  lambda_policy_document = [{
    sid    = "AllowWriteToCloudwatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [element(concat(aws_cloudwatch_log_group.lambda[*].arn, tolist([""])), 0)]
  }]

  lambda_policy_document_kms = var.kms_key_arn != "" ? [{
    sid       = "AllowKMSDecrypt"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]
  }] : []
}

data "aws_iam_policy_document" "sns_feedback" {
  count = local.create_sns_feedback_role ? 1 : 0

  statement {
    sid    = "PermitDeliveryStatusMessagesToCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "sns_feedback_role" {
  count = local.create_sns_feedback_role ? 1 : 0

  name                  = var.sns_topic_feedback_role_name
  description           = var.sns_topic_feedback_role_description
  path                  = var.sns_topic_feedback_role_path
  force_detach_policies = var.sns_topic_feedback_role_force_detach_policies
  permissions_boundary  = var.sns_topic_feedback_role_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.sns_feedback[0].json

  tags = merge(var.tags, var.sns_topic_feedback_role_tags)
}
