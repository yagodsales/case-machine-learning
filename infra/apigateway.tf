# API Gateway REST API definition
resource "aws_api_gateway_rest_api" "titanic_gw_api" {
  name        = "titanic_gw_api"
  description = "REST API for Lambda"

  body = templatefile(
    "${path.module}/../openapi.yaml", {
      region               = var.aws_region,
      account_id           = var.account_id,
      lambda_function_name = aws_lambda_function.titanic.function_name
    }
  )

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "titanic_deployment" {
  depends_on  = [aws_api_gateway_rest_api.titanic_gw_api]
  rest_api_id = aws_api_gateway_rest_api.titanic_gw_api.id
  triggers = {
    redeployment = sha1(file("${path.module}/../openapi.yaml"))
  }
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id = aws_api_gateway_rest_api.titanic_gw_api.id
  deployment_id = aws_api_gateway_deployment.titanic_deployment.id
  stage_name = "dev"
}

resource "aws_lambda_permission" "allow_apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.titanic.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.titanic_gw_api.id}/${aws_api_gateway_stage.dev.stage_name}/*/*"
}

