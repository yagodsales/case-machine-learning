data "aws_iam_policy_document" "assume_role"{
    statement{
        effect = "Allow"

        principals{
            type        = "Service"
            identifiers = ["lambda.amazonaws.com","dynamodb.amazonaws.com"]
        }

        actions = ["sts:AssumeRole"]
    }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../modelo"
  output_path = "lambda_modelo.zip"
}
