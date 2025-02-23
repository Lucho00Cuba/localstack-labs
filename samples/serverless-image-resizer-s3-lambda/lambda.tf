## IAM SSM Policy

resource "aws_iam_policy" "lambdas_ssm" {
  name   = "LambdasAccessSsm"
  policy = file("${path.root}/policies/lambda_ssm.json")
}

## Presign Lambda

resource "aws_iam_role" "presign_lambda_role" {
  name               = "PresignLambdaRole"
  assume_role_policy = file("${path.root}/policies/lambda.json")
}

resource "aws_iam_policy" "presign_lambda_s3_buckets" {
  name = "PresignLambdaS3AccessPolicy"
  policy = templatefile("${path.root}/policies/presign_lambda_s3_buckets.json.tpl", {
    images_bucket = aws_s3_bucket.images_bucket.bucket
  })
}

resource "aws_iam_role_policy_attachment" "presign_lambda_s3_buckets" {
  role       = aws_iam_role.presign_lambda_role.name
  policy_arn = aws_iam_policy.presign_lambda_s3_buckets.arn
}

resource "aws_iam_role_policy_attachment" "presign_lambda_ssm" {
  role       = aws_iam_role.presign_lambda_role.name
  policy_arn = aws_iam_policy.lambdas_ssm.arn
}

data "archive_file" "presign_artifact" {
  type        = "zip"
  source_dir  = "${path.root}/lambdas/presign"
  output_path = "${path.root}/lambdas/presign/lambda.zip"
  excludes    = ["*.zip"]
}

resource "aws_lambda_function" "presign_lambda" {
  function_name    = "presign"
  filename         = data.archive_file.presign_artifact.output_path
  handler          = "handler.handler"
  runtime          = "python3.9"
  timeout          = 10
  role             = aws_iam_role.presign_lambda_role.arn
  source_code_hash = data.archive_file.presign_artifact.output_base64sha256

  environment {
    variables = local.env_variables
  }
}

resource "aws_lambda_function_url" "presign_lambda_function" {
  function_name      = aws_lambda_function.presign_lambda.function_name
  authorization_type = "NONE"
}

## List images lambda

resource "aws_iam_role" "list_lambda_role" {
  name               = "ListLambdaRole"
  assume_role_policy = file("${path.root}/policies/lambda.json")
}

resource "aws_iam_policy" "list_lambda_s3_buckets" {
  name = "ListLambdaS3AccessPolicy"
  policy = templatefile("${path.root}/policies/list_lambda_s3_buckets.json.tpl", {
    images_bucket         = aws_s3_bucket.images_bucket.bucket,
    images_resized_bucket = aws_s3_bucket.image_resized_bucket.bucket
  })
}

resource "aws_iam_role_policy_attachment" "list_lambda_s3_buckets" {
  role       = aws_iam_role.list_lambda_role.name
  policy_arn = aws_iam_policy.list_lambda_s3_buckets.arn
}

resource "aws_iam_role_policy_attachment" "list_lambda_ssm" {
  role       = aws_iam_role.list_lambda_role.name
  policy_arn = aws_iam_policy.lambdas_ssm.arn
}

data "archive_file" "list_artifact" {
  type        = "zip"
  source_dir  = "${path.root}/lambdas/list"
  output_path = "${path.root}/lambdas/list/lambda.zip"
  excludes    = ["*.zip"]
}

resource "aws_lambda_function" "list_lambda" {
  function_name    = "list"
  filename         = data.archive_file.list_artifact.output_path
  handler          = "handler.handler"
  runtime          = "python3.9"
  timeout          = 10
  role             = aws_iam_role.list_lambda_role.arn
  source_code_hash = data.archive_file.list_artifact.output_base64sha256

  environment {
    variables = local.env_variables
  }
}

resource "aws_lambda_function_url" "list_lambda_function" {
  function_name      = aws_lambda_function.list_lambda.function_name
  authorization_type = "NONE"
}

## Resize lambda

resource "aws_iam_role" "resize_lambda_role" {
  name               = "ResizeLambdaRole"
  assume_role_policy = file("${path.root}/policies/lambda.json")
}

resource "aws_iam_policy" "resize_lambda_s3_buckets" {
  name = "ResizeLambdaS3Buckets"
  policy = templatefile("${path.root}/policies/resize_lambda_s3_buckets.json.tpl", {
    images_resized_bucket = aws_s3_bucket.image_resized_bucket.bucket
  })
}

resource "aws_iam_role_policy_attachment" "resize_lambda_s3_buckets" {
  role       = aws_iam_role.resize_lambda_role.name
  policy_arn = aws_iam_policy.resize_lambda_s3_buckets.arn
}

resource "aws_iam_policy" "resize_lambda_sns" {
  name = "ResizeLambdaSNS"
  policy = templatefile("${path.root}/policies/resize_lambda_sns.json.tpl", {
    failure_notifications_topic_arn = aws_sns_topic.failure_notifications.arn,
    resize_lambda_arn               = aws_lambda_function.resize_lambda.arn
  })
}

resource "aws_iam_role_policy_attachment" "resize_lambda_sns" {
  role       = aws_iam_role.resize_lambda_role.name
  policy_arn = aws_iam_policy.resize_lambda_sns.arn
}

resource "aws_iam_role_policy_attachment" "resize_lambda_ssm" {
  role       = aws_iam_role.resize_lambda_role.name
  policy_arn = aws_iam_policy.lambdas_ssm.arn
}

## deps in zip
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${path.root}/lambdas/resize/package
      mkdir -p ${path.root}/lambdas/resize/package

      docker run --rm \
        -v "${path.root}/lambdas/resize/:/var/task" \
        public.ecr.aws/sam/build-python3.9 \
        /bin/sh -c "pip install -r /var/task/requirements.txt -t /var/task/package --platform manylinux2014_x86_64 --only-binary=:all:"

      cp -r ${path.root}/lambdas/resize/handler.py ${path.root}/lambdas/resize/package/
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

data "archive_file" "resize_artifact" {
  type        = "zip"
  source_dir  = "${path.root}/lambdas/resize/package"
  output_path = "${path.root}/lambdas/resize/lambda.zip"
  excludes    = ["*.zip"]
  depends_on  = [null_resource.install_dependencies]
}

resource "aws_lambda_function" "resize_lambda" {
  function_name    = "resize"
  handler          = "handler.handler"
  runtime          = "python3.9"
  role             = aws_iam_role.resize_lambda_role.arn
  source_code_hash = data.archive_file.resize_artifact.output_base64sha256
  filename         = data.archive_file.resize_artifact.output_path

  depends_on = [
    data.archive_file.resize_artifact
  ]

  environment {
    variables = local.env_variables
  }

  dead_letter_config {
    target_arn = aws_sns_topic.failure_notifications.arn
  }
}
