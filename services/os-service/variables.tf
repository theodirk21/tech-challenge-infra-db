variable "aws_region" {
  description = "Região da AWS onde o banco será criado"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado como prefixo dos recursos"
  type        = string
  default     = "tech-challenge"
}

variable "environment" {
  description = "Ambiente (o edital só exige produção, mas fica parametrizado)"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "ID da VPC onde o RDS será criado (mesma VPC do EKS ou uma com rota até ela)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnet IDs privadas para o DB Subnet Group"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security Group do cluster EKS (ou dos nodes), para liberar acesso ao banco"
  type        = string
}
