output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.sample-mock.id
}

output "api_gateway_invoke_url" {
  description = "The invoke URL of the API Gateway"
  value       = "http://${aws_api_gateway_rest_api.sample-mock.id}.execute-api.localhost.localstack.cloud:4566/${aws_api_gateway_stage.stage.stage_name}/"
}

output "root_resource_id" {
  description = "The resource ID of the root / path"
  value       = aws_api_gateway_rest_api.sample-mock.root_resource_id
}