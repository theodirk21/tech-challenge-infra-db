output "table_name" {
  description = "Nome (previsível) da tabela DynamoDB"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = aws_dynamodb_table.this.arn
}

output "payment_index_name" {
  description = "Nome do GSI para consulta por ID de pagamento do Mercado Pago"
  value       = local.payment_index_name
}

output "access_policy_arn" {
  description = "ARN da policy IAM de acesso à tabela (null se create_access_policy = false)"
  value       = try(aws_iam_policy.access[0].arn, null)
}
