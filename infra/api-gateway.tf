resource "aws_api_gateway_rest_api" "api_titanic"{
    name = "api_titanic"
    description = "API para case técnico"

    endpoint_configuration {
      types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_resource" "api_titanic_resource" {
    parent_id       = aws_api_gateway_rest_api.api_titanic.root_resource_id
    path_part       = "transaction"
    rest_api_id     = aws_api_gateway_rest_api.api_titanic.id
}

//GET /transaction
resource "aws_api_gateway_method" "transaction_gw_api_method_get" {
    authorization   = "NONE"
    http_method     = "GET"
    resource_id     = aws_api_gateway_resource.api_titanic_resource.id
    rest_api_id     = aws_api_gateway_rest_api.api_titanic.id
}

resource "aws_api_gateway_integration" "transaction_lambda_integration_get" {
    http_method = aws_api_gateway_method.transaction_gw_api_method_get.http_method
    resource_id = aws_api_gateway_resource.api_titanic_resource.id
    rest_api_id = aws_api_gateway_rest_api.api_titanic.id
    type        = "AWS_PROXY"

    integration_http_method     = "POST" #para lambda_proxy, sempre deve ser POST
    uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "transaction_response_200_get" {
  http_method = aws_api_gateway_method.transaction_gw_api_method_get.http_method
  resource_id = aws_api_gateway_resource.api_titanic_resource.id
  rest_api_id = aws_api_gateway_rest_api.api_titanic.id
  status_code = "200"
}

//POST /transaction
resource "aws_api_gateway_method" "transaction_gw_api_method_post" {
    authorization   = "NONE"
    http_method     = "POST"
    resource_id     = aws_api_gateway_resource.api_titanic_resource.id
    rest_api_id     = aws_api_gateway_rest_api.api_titanic.id
}

resource "aws_api_gateway_integration" "transaction_lambda_integration_post" {
    http_method = aws_api_gateway_method.transaction_gw_api_method_post.http_method
    resource_id = aws_api_gateway_resource.api_titanic_resource.id
    rest_api_id = aws_api_gateway_rest_api.api_titanic.id
    type        = "AWS_PROXY"

    integration_http_method     = "POST" #para lambda_proxy, sempre deve ser POST
    uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "transaction_response_200_post" {
  http_method = aws_api_gateway_method.transaction_gw_api_method_post.http_method
  resource_id = aws_api_gateway_resource.api_titanic_resource.id
  rest_api_id = aws_api_gateway_rest_api.api_titanic.id
  status_code = "200"
}

resource "aws_api_gateway_deployment" "api_deployment" {
    rest_api_id = aws_api_gateway_rest_api.api_titanic.id

    triggers = {
      redeployment = timestamp()
    }

    lifecycle {
      create_before_destroy = true
    }

    depends_on = [
         aws_api_gateway_integration.transaction_lambda_integration_get,
         aws_api_gateway_integration.transaction_lambda_integration_post
     ]
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "apigateway.amazonaws.com"
    statement_id = "AllowExecutionFromAPIGateway"
    source_arn = "${aws_api_gateway_rest_api.api_titanic.execution_arn}/*"
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_titanic.id
  stage_name    = var.stage_name
}