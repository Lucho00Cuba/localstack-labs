output "presign_lambda_function_url" {
  value = aws_lambda_function_url.presign_lambda_function.function_url
}

output "list_lambda_function_url" {
  value = aws_lambda_function_url.list_lambda_function.function_url
}

output "cloudfront_url" {
  value = "Now open the Web app under: http://${aws_cloudfront_distribution.cdn.domain_name}"
}
