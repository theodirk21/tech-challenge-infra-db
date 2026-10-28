terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Tabela DynamoDB do Billing Service, isolada dos demais serviços.
module "table" {
  source = "../../modules/dynamodb-table"

  project_name = var.project_name
  environment  = var.environment
  service_name = "billing-service"

  create_access_policy = var.create_access_policy
}
