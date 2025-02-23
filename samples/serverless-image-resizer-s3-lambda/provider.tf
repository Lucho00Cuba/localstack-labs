provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    iam        = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    sns        = "http://localhost:4566"
    ssm        = "http://localhost:4566"
    cloudfront = "http://localhost:4566"
    s3         = "http://s3.localhost.localstack.cloud:4566"
  }
}
