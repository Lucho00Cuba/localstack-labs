# 🚀 LocalStack - AWS Labs

This repository provides a **Docker Compose** setup to run **LocalStack** in a container. It is intended as a learning resource for testing and experimenting with AWS services locally.

## 🔗 Repository

For examples and Terraform configurations, please refer to the official [LocalStack Terraform Samples](https://github.com/localstack-samples/localstack-terraform-samples) repository.

## 📌 Requirements

Before running LocalStack, ensure you have the following installed:

- 🐳 [Docker](https://docs.docker.com/get-docker/)
- 📦 [Docker Compose](https://docs.docker.com/compose/install/)
- ☁️ [LocalStack Community Account](https://docs.localstack.cloud/)
- 🔧 [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- 🖥️ [AWS CLI](https://aws.amazon.com/cli/)
  ```bash
  pip install awscli
  ```
- 🏗️ [LocalStack CLI](https://docs.localstack.cloud/references/localstack-cli/)
  ```bash
  pip install localstack
  ```
- 📝 `tflocal` wrapper script
  ```bash
  pip install terraform-local
  ```
- 📜 `awslocal` wrapper script
  ```bash
  pip install awscli-local
  ```

## ☁️ LocalStack

LocalStack is a cloud service emulator for working with AWS services such as S3 and DynamoDB locally among other services.

For more information, see the [LocalStack documentation](https://docs.localstack.cloud/home/).

## ⚡ Usage

### 🔄 Actions

To run LocalStack, use the following commands:

```bash
## 🚀 Start LocalStack
# Using Docker Compose
docker-compose up -d

# Using LocalStack CLI
localstack start -d

## 🛑 Stop LocalStack
# Using Docker Compose
docker-compose down

# Using LocalStack CLI
localstack stop

## 📊 Check Status
# Using Docker Compose
docker-compose ps

# Using LocalStack CLI
localstack status
```

## 📄 Resources

- 📘 [LocalStack Documentation](https://docs.localstack.cloud/)
- 📜 [AWS CLI Commands](https://docs.aws.amazon.com/cli/latest/reference/)
- 🏗️ [LocalStack Terraform Samples Repository](https://github.com/localstack-samples/localstack-terraform-samples)
