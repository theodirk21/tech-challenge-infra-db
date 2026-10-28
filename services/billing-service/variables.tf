variable "aws_region" {
  description = "Região da AWS onde a tabela será criada"
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

variable "create_access_policy" {
  description = "Cria a policy IAM de acesso à tabela. Deixe false se a conta (ex.: laboratório) bloquear a criação de IAM."
  type        = bool
  default     = false
}
