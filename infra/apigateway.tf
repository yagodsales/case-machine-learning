resource "aws_api_gateway_rest_api" "titanic_gw_api"{
    name = "titanic_gw_api"
    description = "REST API for lambda"
    body = templatefile("${path.module}/../openapi.yaml", {
    region               = var.aws_region,
    account_id           = var.account_id,
    lambda_function_name = aws_lambda_function.lambda.function_name
  })

    endpoint_configuration {
      types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_resource" "titanic_gw_api_resource" {
    parent_id       = aws_api_gateway_rest_api.titanic_gw_api.root_resource_id
    path_part       = "sobreviventes"
    rest_api_id     = aws_api_gateway_rest_api.titanic_gw_api.id
}

resource "aws_api_gateway_method" "gw_api_method_post" {
    authorization   = "NONE"
    http_method     = "POST"
    resource_id     = aws_api_gateway_resource.titanic_gw_api_resource.id
    rest_api_id     = aws_api_gateway_rest_api.titanic_gw_api.id
}

resource "aws_api_gateway_method" "gw_api_method_get" {
    authorization   = "NONE"
    http_method     = "GET"
    resource_id     = aws_api_gateway_resource.titanic_gw_api_resource.id
    rest_api_id     = aws_api_gateway_rest_api.titanic_gw_api.id
}


resource "aws_api_gateway_integration" "lambda_integration_post" {
    http_method = aws_api_gateway_method.gw_api_method_post.http_method
    resource_id = aws_api_gateway_resource.titanic_gw_api_resource.id
    rest_api_id = aws_api_gateway_rest_api.titanic_gw_api.id
    type        = "AWS_PROXY"

    integration_http_method     = "POST" #para lambda_proxy, sempre deve ser POST
    uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_integration_get" {
    http_method = aws_api_gateway_method.gw_api_method_get.http_method
    resource_id = aws_api_gateway_resource.titanic_gw_api_resource.id
    rest_api_id = aws_api_gateway_rest_api.titanic_gw_api.id
    type        = "AWS_PROXY"

    integration_http_method     = "POST" #para lambda_proxy, sempre deve ser POST
    uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200_post" {
  rest_api_id = aws_api_gateway_rest_api.titanic_gw_api.id
  resource_id = aws_api_gateway_resource.titanic_gw_api_resource.id
  http_method = aws_api_gateway_method.gw_api_method_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "response_200_get" {
  rest_api_id = aws_api_gateway_rest_api.titanic_gw_api.id
  resource_id = aws_api_gateway_resource.titanic_gw_api_resource.id
  http_method = aws_api_gateway_method.gw_api_method_get.http_method
  status_code = "200"
}



resource "aws_api_gateway_deployment" "api_deployment" {
    rest_api_id = aws_api_gateway_rest_api.titanic_gw_api.id

      triggers = {
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.titanic_gw_api_resource.id,
            aws_api_gateway_method.gw_api_method_post.id,
            aws_api_gateway_method.gw_api_method_get.id,
            aws_api_gateway_integration.lambda_integration_post.id,
            aws_api_gateway_integration.lambda_integration_get.id,
        ]))
    }

    lifecycle {
      create_before_destroy = true
    }

    depends_on = [ 
        aws_api_gateway_integration.lambda_integration_post,
        aws_api_gateway_integration.lambda_integration_get,
    ]
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "apigateway.amazonaws.com"
    statement_id = "AllowExecutionFromAPIGateway"
    source_arn = "${aws_api_gateway_rest_api.titanic_gw_api.execution_arn}/*"
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.titanic_gw_api.id
  stage_name    = var.stage_name
}