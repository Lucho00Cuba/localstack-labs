# Serverless Image Resizer

This project is a fork of [localstack-samples/sample-serverless-image-resizer-s3-lambda](https://github.com/localstack-samples/sample-serverless-image-resizer-s3-lambda/tree/main), with the goal of practicing the creation of resources using Terraform.

## Architecture Overview

The image resizer function leverages AWS Lambda and S3 to handle image resizing tasks. The architecture involves multiple AWS services integrated together to enable seamless image processing:

![Screenshot at 2023-04-02 01-32-56](https://user-images.githubusercontent.com/3996682/229322761-92f52eec-5bfb-412a-a3cb-8af4ee1fed24.png)

### Components:
1. **AWS Lambda** - The serverless function that resizes images.
2. **S3** - Stores original images and resized images.
3. **SNS (Simple Notification Service)** - Notifies upon failure of the image processing.
5. **IAM Roles** - Manages permissions for Lambda and other AWS services.

## Terraform Setup

### Requirements:
- [Terraform](https://www.terraform.io/downloads.html) 1.0 or higher
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- [LocalStack](https://blog.justme.ovh/posts/run-aws-locally/) installed and running

### Initial Setup:
1. Clone the repository:
   ```bash
    git clone https://github.com/Lucho00Cuba/localstack-labs.git
    cd localstack-labs
   ```

2. Initialize Terraform:
   ```bash
   make init chdir=samples/serverless-image-resizer-s3-lambda
   # or
   cd samples/serverless-image-resizer-s3-lambda
   terraform init
   ```

3. Create a `.env` file in the root directory of the project with the following content:
   ```bash
   LOCALSTACK_AUTH_TOKEN=YOUR_LOCALSTACK_AUTH_TOKEN
   ```
   Replace `YOUR_LOCALSTACK_AUTH_TOKEN` with your LocalStack authentication token.

4. Run the Terraform commands to deploy the resources:
   ```bash
   make apply chdir=samples/serverless-image-resizer-s3-lambda
   # or
   cd samples/serverless-image-resizer-s3-lambda
   terraform apply
   ```