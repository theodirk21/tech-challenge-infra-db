output "table_name" {
  description = "Nome da tabela DynamoDB (o microsserviço usa este nome)"
  value       = module.table.table_name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = module.table.table_arn
}

output "payment_index_name" {
  description = "Nome do GSI para consulta por ID de pagamento do Mercado Pago"
  value       = module.table.payment_index_name
}

output "access_policy_arn" {
  description = "ARN da policy IAM de acesso à tabela (null se create_access_policy = false)"
  value       = module.table.access_policy_arn
}
