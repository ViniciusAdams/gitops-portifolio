terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region
}

resource "aws_iam_role" "lambda_role" {
  name = "trivia_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = { Service = "lambda.amazonaws.com" },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "trivia" {
  function_name = "trivia-game"
  s3_bucket     = var.bucket_name
  s3_key        = var.lambda_s3_key
  runtime       = "python3.11"
  handler       = "lambda_handler.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "TriviaGameAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "trivia_integration" {
  api_id           = aws_apigatewayv2_api.trivia_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.trivia.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "trivia_route" {
  api_id    = aws_apigatewayv2_api.trivia_api.id
  route_key = "GET /trivia"
  target    = "integrations/${aws_apigatewayv2_integration.trivia_integration.id}"
}

# Deploy API Gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.trivia_api.id
  name        = "$default"
  auto_deploy = true
}

# Grant permission for API Gateway to invoke the Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trivia.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.trivia_api.execution_arn}/*/*"
}
