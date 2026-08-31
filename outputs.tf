output "db_endpoint" {
  description = "Endpoint (host:port) do RDS, usado pela aplicação para conectar"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Host do RDS, sem a porta"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Porta do banco"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.this.db_name
}

output "db_security_group_id" {
  description = "ID do Security Group do banco (caso outro repo precise referenciar)"
  value       = aws_security_group.db.id
}

output "secrets_manager_secret_arn" {
  description = "ARN do secret no Secrets Manager com as credenciais completas de acesso"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
