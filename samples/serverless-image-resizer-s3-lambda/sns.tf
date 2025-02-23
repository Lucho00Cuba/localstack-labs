# SNS Topic for failure notifications
resource "aws_sns_topic" "failure_notifications" {
  name = "image_resize_failures"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.failure_notifications.arn
  protocol  = "email"
  endpoint  = local.failure_notifications_email
}

# S3 Bucket Notification for Lambda trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.images_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.resize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "s3_invoke_resize_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resize_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images_bucket.arn
}