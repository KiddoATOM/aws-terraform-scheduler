resource "aws_lambda_function" "scheduler_starter" {
  filename      = "${path.module}/start_instance.zip"
  function_name = "scheduler_starter"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "start_instance.lambda_handler"
  timeout       = 45

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${path.module}/start_instance.zip")

  runtime = "python3.8"

  environment {
    variables = {
      SchedulerTagName  = var.scheduler_tag_name
      SchedulerTagValue = var.scheduler_tag_value
    }
  }
  tags = merge(map("DeployedBy", "terraform"), var.custom_tags)
}

resource "aws_lambda_function" "scheduler_stoper" {
  filename      = "${path.module}/stop_instance.zip"
  function_name = "scheduler_stoper"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "stop_instance.lambda_handler"
  timeout       = 45

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${path.module}/stop_instance.zip")

  runtime = "python3.8"

  environment {
    variables = {
      SchedulerTagName  = var.scheduler_tag_name
      SchedulerTagValue = var.scheduler_tag_value
      Repositories      = var.repositories
      Buckets           = var.buckets
    }
  }
  tags = merge(map("DeployedBy", "terraform"), var.custom_tags)
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "billing_monitor_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = merge(map("DeployedBy", "terraform"), var.custom_tags)

}

resource "aws_cloudwatch_log_group" "scheduler_starter" {
  name              = "/aws/lambda/${aws_lambda_function.scheduler_starter.function_name}"
  retention_in_days = var.log_retention

  tags = merge(map("DeployedBy", "terraform"), var.custom_tags)

}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "scheduler_policy" {
  name        = "lambda_scheduler"
  path        = "/"
  description = "IAM policy for stop and start instance. Clean ECR repositories"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:StartInstances",
                "ec2:DescribeTags",
                "ec2:DescribeRegions",
                "ecr:BatchDeleteImage",
                "ec2:StopInstances",
                "ecr:ListImages",
                "ec2:DescribeInstanceStatus",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "scheduler" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}

resource "aws_cloudwatch_event_rule" "starter" {
  name        = "Invoke_scheduler_starter"
  description = "Invoke scheduler starter"

  schedule_expression = var.start_time
}

resource "aws_cloudwatch_event_target" "scheduler_starter" {
  rule = aws_cloudwatch_event_rule.starter.name
  arn  = aws_lambda_function.scheduler_starter.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_scheduler_starter_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_starter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.starter.arn
}

resource "aws_cloudwatch_event_rule" "stoper" {
  name        = "Invoke_scheduler_stoper"
  description = "Invoke scheduler stoper"

  schedule_expression = var.stop_time
}

resource "aws_cloudwatch_event_target" "scheduler_stoper" {
  rule = aws_cloudwatch_event_rule.stoper.name
  arn  = aws_lambda_function.scheduler_stoper.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_scheduler_stoper_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_stoper.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stoper.arn
}
