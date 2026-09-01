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

variable "db_name" {
  description = "Nome do banco de dados dentro da instância"
  type        = string
  default     = "techchallenge"
}

variable "db_username" {
  description = "Usuário master do banco"
  type        = string
  default     = "techchallenge_admin"
}

variable "postgres_version" {
  description = "Versão do engine Postgres"
  type        = string
  default     = "16"
}

variable "db_parameter_group_family" {
  description = "Família do parameter group (precisa bater com a major version do Postgres)"
  type        = string
  default     = "postgres16"
}

variable "db_instance_class" {
  description = "Classe da instância RDS. db.t3.micro entra no free tier da AWS."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento alocado em GB"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Se true, cria réplica em outra AZ (custo maior). Para o desafio, false já atende."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Dias de retenção de backup automático"
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Se true, não cria snapshot final ao destruir (útil já que a infra será derrubada após o vídeo)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Proteção contra destroy acidental. Deixar false facilita derrubar a infra após a gravação."
  type        = bool
  default     = false
}
