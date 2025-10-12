output "api_endpoint" {
  value       = aws_apigatewayv2_api.trivia_api_endpoint
  description = "Base URL of the deployed API"
}

output "lambda_api_url" {
  description = "Invoke URL of the API Gateway endpoint"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}
