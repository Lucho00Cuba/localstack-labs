resource "aws_ssm_parameter" "images_bucket_ssm" {
  name  = "/localstack-thumbnail-app/buckets/images"
  type  = "String"
  value = aws_s3_bucket.images_bucket.bucket
}

resource "aws_ssm_parameter" "images_resized_bucket_ssm" {
  name  = "/localstack-thumbnail-app/buckets/resized"
  type  = "String"
  value = aws_s3_bucket.image_resized_bucket.bucket
}
