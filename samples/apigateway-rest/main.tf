# AWS API Gateway MOCK integration
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "apigateway" {
  name               = "rest-apigw-mock"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume.json
}

data "aws_iam_policy_document" "apigw_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_api_gateway_rest_api" "sample-mock" {
  name        = "rest-demo"
  description = "An API REST"
}

resource "aws_api_gateway_resource" "livez_resource" {
  path_part   = "livez"
  parent_id   = aws_api_gateway_rest_api.sample-mock.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
}

resource "aws_api_gateway_resource" "readyz_resource" {
  path_part   = "readyz"
  parent_id   = aws_api_gateway_rest_api.sample-mock.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
}

resource "aws_api_gateway_method" "get_livez_method" {
  rest_api_id   = aws_api_gateway_rest_api.sample-mock.id
  resource_id   = aws_api_gateway_resource.livez_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_readyz_method" {
  rest_api_id   = aws_api_gateway_rest_api.sample-mock.id
  resource_id   = aws_api_gateway_resource.readyz_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "get_livez_return_200" {
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
  resource_id = aws_api_gateway_resource.livez_resource.id
  http_method = aws_api_gateway_method.get_livez_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "get_readyz_return_200" {
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
  resource_id = aws_api_gateway_resource.readyz_resource.id
  http_method = aws_api_gateway_method.get_readyz_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "get_livez_integration" {
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
  resource_id = aws_api_gateway_resource.livez_resource.id
  http_method = aws_api_gateway_method.get_livez_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }

  depends_on = [aws_api_gateway_method.get_livez_method]
}

resource "aws_api_gateway_integration" "get_readyz_integration" {
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
  resource_id = aws_api_gateway_resource.readyz_resource.id
  http_method = aws_api_gateway_method.get_readyz_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }

  depends_on = [aws_api_gateway_method.get_readyz_method]
}

resource "aws_api_gateway_integration_response" "get_livez_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
  resource_id = aws_api_gateway_resource.livez_resource.id
  http_method = aws_api_gateway_method.get_livez_method.http_method
  status_code = aws_api_gateway_method_response.get_livez_return_200.status_code

  response_templates = {
    "application/json" = jsonencode({
      statusCode = 200
      message    = "Hello from /livez"
    })
  }

  depends_on = [
    aws_api_gateway_method.get_livez_method,
    aws_api_gateway_method_response.get_livez_return_200,
    aws_api_gateway_integration.get_livez_integration
  ]
}

resource "aws_api_gateway_integration_response" "get_readyz_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
  resource_id = aws_api_gateway_resource.readyz_resource.id
  http_method = aws_api_gateway_method.get_readyz_method.http_method
  status_code = aws_api_gateway_method_response.get_readyz_return_200.status_code

  response_templates = {
    "application/json" = jsonencode({
      statusCode = 200
      message    = "Hello from /readyz"
    })
  }

  depends_on = [
    aws_api_gateway_method.get_readyz_method,
    aws_api_gateway_method_response.get_readyz_return_200,
    aws_api_gateway_integration.get_readyz_integration
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.sample-mock.id
  description = "Deployed at ${timestamp()}"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.sample-mock.body,
      aws_api_gateway_integration_response.get_livez_integration_response.response_templates["application/json"],
      aws_api_gateway_integration_response.get_readyz_integration_response.response_templates["application/json"],
    ]))
    # redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration_response.get_livez_integration_response,
    aws_api_gateway_integration_response.get_readyz_integration_response
  ]
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.sample-mock.id
  stage_name    = "dev"
}
