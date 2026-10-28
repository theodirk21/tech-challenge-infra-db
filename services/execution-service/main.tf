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

# Banco PostgreSQL do Execution Service, isolado dos demais serviços.
module "db" {
  source = "../../modules/rds-postgres"

  project_name = var.project_name
  environment  = var.environment
  service_name = "execution-service"

  db_name     = "execution_service"
  db_username = "execution_service_admin"

  vpc_id                = var.vpc_id
  private_subnet_ids    = var.private_subnet_ids
  eks_security_group_id = var.eks_security_group_id
}
