module "ecs_scheduler_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.19.2"
  namespace  = var.namespace
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  name       = "ecs-scheduler-${var.name}"
}

resource "aws_iam_policy" "ecs_update" {
  name        = module.ecs_scheduler_label.id
  path        = "/"
  description = "Call update-service on ECS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ECS:UpdateService"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_scheduler" {
  name               = module.ecs_scheduler_label.id
  tags               = module.ecs_scheduler_label.tags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_scheduler1" {
  role       = aws_iam_role.ecs_scheduler.name
  policy_arn = aws_iam_policy.ecs_update.arn
}

resource "aws_iam_role_policy_attachment" "ecs_scheduler2" {
  role       = aws_iam_role.ecs_scheduler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "ecs_scheduler" {
  type        = "zip"
  source_file = "${path.module}/lambda/scheduler/scheduler.py"
  output_path = "${path.module}/lambda/dist/scheduler.zip"
}

resource "aws_lambda_function" "ecs_scheduler" {
  filename         = data.archive_file.ecs_scheduler.output_path
  function_name    = module.ecs_scheduler_label.id
  role             = aws_iam_role.ecs_scheduler.arn
  handler          = "scheduler.lambda_handler"
  runtime          = "python3.7"
  source_code_hash = filebase64sha256("${data.archive_file.ecs_scheduler.output_path}")
  description      = "Starts/stops ecs tasks once requested"
}

resource "aws_lambda_permission" "cloudwatch_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.ecs_scheduler.function_name
  source_arn    = aws_cloudwatch_event_rule.ecs_scheduler_start.arn
}

resource "aws_lambda_permission" "cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatch2"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.ecs_scheduler.function_name
  source_arn    = aws_cloudwatch_event_rule.ecs_scheduler_stop.arn
}

resource "aws_cloudwatch_event_rule" "ecs_scheduler_start" {
  name        = "${module.ecs_scheduler_label.id}-start"
  description = "Start ECS tasks"
  schedule_expression = var.cron_start
}

resource "aws_cloudwatch_event_target" "ecs_scheduler_start" {
  count     = length(var.ecs_services)
  rule      = aws_cloudwatch_event_rule.ecs_scheduler_start.name
  arn       = aws_lambda_function.ecs_scheduler.arn
  input     = "{\"clusterName\":\"${var.cluster_name}\",\"serviceName\":\"${var.ecs_services[count.index]["service_name"]}\", \"desiredCount\":${var.ecs_services[count.index]["desired_count"]},\"AWSRegion\":\"${var.region}\",\"action\":\"start\"}"
}

resource "aws_cloudwatch_event_rule" "ecs_scheduler_stop" {
  name        = "${module.ecs_scheduler_label.id}-stop"
  description = "Start ECS tasks"
  schedule_expression = var.cron_stop
}

resource "aws_cloudwatch_event_target" "ecs_scheduler_stop" {
  count     = length(var.ecs_services)
  rule      = aws_cloudwatch_event_rule.ecs_scheduler_stop.name
  arn       = aws_lambda_function.ecs_scheduler.arn
  input     = "{\"clusterName\":\"${var.cluster_name}\",\"serviceName\":\"${var.ecs_services[count.index]["service_name"]}\", \"desiredCount\":${var.ecs_services[count.index]["desired_count"]},\"AWSRegion\":\"${var.region}\",\"action\":\"stop\"}"
}

