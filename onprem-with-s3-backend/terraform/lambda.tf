data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_ec2_permissions" {
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeInstances", "ec2:StartInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_ec2" {
  name   = "LambdaEC2DescribePolicy"
  policy = data.aws_iam_policy_document.lambda_ec2_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_attach_ec2" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_ec2.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "ec2-starter.py"
  output_path = "ec2-starter.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "ec2-starter.zip"
  function_name    = "ec2-starter"
  role            = aws_iam_role.iam_for_lambda.arn
  handler         = "ec2-starter.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      INSTANCE_NAME = "vault"
    }
  }
}
