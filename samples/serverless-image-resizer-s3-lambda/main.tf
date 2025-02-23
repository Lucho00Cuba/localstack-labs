locals {
  env_variables = {
    STAGE          = terraform.workspace == "default" ? "local" : terraform.workspace
    LOCALSTACK_URL = "http://localhost:4566"
  }

  images_bucket               = "localstack-thumbnails-app-images"
  image_resized_bucket        = "localstack-thumbnails-app-resized"
  website_bucket              = "localstack-website"
  failure_notifications_email  = "my-email@example.com"
}