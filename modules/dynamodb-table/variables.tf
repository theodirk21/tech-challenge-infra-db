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

variable "service_name" {
  description = "Nome do microsserviço dono da tabela (ex.: billing-service)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.service_name))
    error_message = "service_name deve usar minúsculas, números e hífen, começando por letra (2 a 31 caracteres)."
  }
}

variable "hash_key" {
  description = "Partition key da tabela (ID da ordem de serviço)"
  type        = string
  default     = "osId"
}

variable "range_key" {
  description = "Sort key da tabela; distingue o tipo de item (ex.: ORCAMENTO#<id>, PAGAMENTO#<id>)"
  type        = string
  default     = "sk"
}

variable "payment_id_attribute" {
  description = "Atributo com o ID do pagamento no Mercado Pago; indexado pelo GSI para o webhook localizar o item"
  type        = string
  default     = "paymentId"
}

variable "enable_pitr" {
  description = "Habilita point-in-time recovery"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Habilita TTL para expirar itens antigos (ex.: orçamentos não aprovados)"
  type        = bool
  default     = true
}

variable "ttl_attribute" {
  description = "Atributo numérico (epoch em segundos) usado pelo TTL"
  type        = string
  default     = "expiresAt"
}

variable "deletion_protection" {
  description = "Proteção contra exclusão acidental. Deixar false facilita derrubar a infra após a gravação."
  type        = bool
  default     = false
}

variable "create_access_policy" {
  description = "Cria uma aws_iam_policy com acesso somente a esta tabela. Deixe false se a conta (ex.: laboratório) bloquear a criação de IAM."
  type        = bool
  default     = false
}
