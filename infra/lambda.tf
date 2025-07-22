resource "aws_iam_role" "iam_for_lambda"{
    name                    = "iam_for_lambda"
    assume_role_policy      = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_logging" {
    name = "lambda_logging"
    path = "/"
    description = "IAM policy for logging from a lambda"

    policy = <<EOF
    {
        "Version":"2012-10-17",
        "Statement": [
            {
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            },
            {
                "Action": [
                    "dynamodb:*"
                ],
                "Resource": "*",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role = aws_iam_role.iam_for_lambda.name
    policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "titanic" {
    depends_on = [
    null_resource.ecr_image
  ]
    timeout = 60
  memory_size = 512
    function_name      = "titanic_lambda"
    role               = aws_iam_role.iam_for_lambda.arn
    image_uri     = "${aws_ecr_repository.repo-lambda.repository_url}:latest"
    package_type  = "Image"

    environment {
    variables = {
      DYNAMO_TABLE = var.dynamo_table
    }
  }
}


resource "aws_cloudwatch_log_group" "example"{
    name = "/aws/lambda/${aws_lambda_function.titanic.function_name}"
    retention_in_days = var.log_retention_days
}