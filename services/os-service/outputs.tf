output "db_endpoint" {
  description = "Endpoint (host:port) do RDS"
  value       = module.db.db_endpoint
}

output "db_address" {
  description = "Host do RDS, sem a porta"
  value       = module.db.db_address
}

output "db_port" {
  description = "Porta do banco"
  value       = module.db.db_port
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = module.db.db_name
}

output "db_security_group_id" {
  description = "ID do Security Group do banco"
  value       = module.db.db_security_group_id
}

output "secrets_manager_secret_name" {
  description = "Nome do secret com as credenciais (o microsserviço lê por este nome)"
  value       = module.db.secrets_manager_secret_name
}

output "secrets_manager_secret_arn" {
  description = "ARN do secret com as credenciais"
  value       = module.db.secrets_manager_secret_arn
}
