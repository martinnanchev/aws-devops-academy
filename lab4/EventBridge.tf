####################################
# Event Bridge
####################################

resource "aws_cloudwatch_event_rule" "CodeBuild_trigger" {
  name        = "${local.service_name}-eventbridge-codebuild-trigger"
  description = "An Eventbridge rule that triggers a Code Build Action"

  schedule_expression = "cron(0 15 * * ? *)"
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.CodeBuild_trigger.name
  target_id = "SendToCodebuild"
  arn       = aws_codebuild_project.codebuild_admin.arn
  role_arn  = aws_iam_role.event_bridge_role.arn
}

####################################
# IAM POLICY for Event Bridge
####################################


data "aws_iam_policy_document" "event-bridge" {
  statement {

    actions = [
      "codebuild:StartBuild"
    ]

    resources = [
      aws_codebuild_project.codebuild_admin.arn,
    ]
  }
}

resource "aws_iam_policy" "event_bridge_role_policy" {
  name        = "${local.service_name}-eventbridge-policy"
  path        = "/"
  description = "Event Bridge policy"
  policy      = data.aws_iam_policy_document.event-bridge.json
}

resource "aws_iam_role" "event_bridge_role" {
  name               = "${local.service_name}-event-bridge-role"
  assume_role_policy = data.aws_iam_policy_document.assume_event_bridge_policy.json
}

data "aws_iam_policy_document" "assume_event_bridge_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eventbridge_target" {
  policy_arn = aws_iam_policy.event_bridge_role_policy.arn
  role       = aws_iam_role.event_bridge_role.name
}