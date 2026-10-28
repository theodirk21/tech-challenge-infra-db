locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"
  table_name  = "${local.name_prefix}-table"

  # Nome do GSI previsível, usado pelo serviço nas consultas por paymentId.
  payment_index_name = "payment-id-index"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = var.service_name
  }
}

resource "aws_dynamodb_table" "this" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = var.hash_key
  range_key = var.range_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  attribute {
    name = var.range_key
    type = "S"
  }

  attribute {
    name = var.payment_id_attribute
    type = "S"
  }

  # Webhook do Mercado Pago chega com o ID do pagamento, não com o osId.
  global_secondary_index {
    name            = local.payment_index_name
    hash_key        = var.payment_id_attribute
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  ttl {
    enabled        = var.enable_ttl
    attribute_name = var.enable_ttl ? var.ttl_attribute : ""
  }

  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = var.deletion_protection

  tags = merge(local.tags, {
    Name = local.table_name
  })
}

data "aws_iam_policy_document" "access" {
  count = var.create_access_policy ? 1 : 0

  statement {
    sid    = "AcessoTabelaBilling"
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
    ]

    resources = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/index/*",
    ]
  }
}

resource "aws_iam_policy" "access" {
  count = var.create_access_policy ? 1 : 0

  name        = "${local.name_prefix}-dynamodb-access"
  description = "Acesso somente à tabela ${local.table_name}; anexar à role do ${var.service_name} (IRSA)"
  policy      = data.aws_iam_policy_document.access[0].json

  tags = local.tags
}
