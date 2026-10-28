locals {
  # Prefixo único por serviço: evita colisão de nomes quando o módulo é
  # instanciado mais de uma vez (OS Service e Execution Service).
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
  }
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  # Nome previsível: cada microsserviço lê o seu secret pelo nome,
  # sem depender do state (terraform_remote_state) deste repositório.
  name        = "${local.name_prefix}-db-credentials"
  description = "Credenciais de acesso ao RDS Postgres do ${var.service_name}"

  # Exclusão imediata: sem isso, um destroy seguido de novo apply com o mesmo
  # nome falha, pois o secret fica "agendado para exclusão" por 7 a 30 dias.
  recovery_window_in_days = 0

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Permite acesso ao RDS do ${var.service_name} apenas a partir do cluster EKS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres a partir do EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-db-sg"
  })
}

resource "aws_db_parameter_group" "this" {
  name   = "${local.name_prefix}-pg-params"
  family = var.db_parameter_group_family

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "200"
  }

  tags = local.tags
}

resource "aws_db_instance" "this" {
  identifier     = "${local.name_prefix}-db"
  engine         = "postgres"
  engine_version = var.postgres_version

  instance_class    = var.db_instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  multi_az            = var.multi_az
  publicly_accessible = false

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-db"
  })
}
