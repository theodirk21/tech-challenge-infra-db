# tech-challenge-infra-db

Infraestrutura como código (Terraform) para a arquitetura distribuída do **Tech Challenge — Fase 4**.

## Propósito

Este repositório provisiona os recursos de dados dos microsserviços do projeto, seguindo os requisitos da Fase 4:

- cada microsserviço possui sua própria infraestrutura e banco de dados
- pelo menos um banco relacional (SQL) e um banco não relacional (NoSQL)
- isolamento por serviço, sem que um serviço acesse diretamente o banco de outro serviço
- credenciais geradas e armazenadas no AWS Secrets Manager
- provisionamento automatizado via Terraform, com módulos reutilizáveis

O repositório não contém a aplicação em si, apenas a parte de infraestrutura.

## Arquitetura atual

A infraestrutura foi organizada em módulos e serviços independentes:

- `modules/rds-postgres`
  - provisiona uma instância Amazon RDS PostgreSQL para um microsserviço
  - cria subnet group, security group, parameter group, secret no Secrets Manager e instância RDS
- `modules/dynamodb-table`
  - provisiona a tabela DynamoDB do Billing Service
  - cria tabela, GSI para consulta por `paymentId` e política de acesso opcional
- `services/os-service`
  - cria o banco PostgreSQL do OS Service
- `services/execution-service`
  - cria o banco PostgreSQL do Execution Service
- `services/billing-service`
  - cria a tabela DynamoDB do Billing Service

## Requisitos da Fase 4 atendidos

Conforme o enunciado do PDF, este repositório atende aos requisitos de infraestrutura para microsserviços:

- 3 microsserviços com infraestrutura isolada
- banco relacional para serviços de domínio/ordens e execução
- banco NoSQL para billing/pagamentos
- isolamento de dados por serviço
- suporte para `Saga Pattern`, mensageria e comunicação desacoplada entre serviços
- credenciais e dados sensíveis não hardcoded

## Tecnologias

- Terraform `>= 1.5`
- AWS provider `~> 5.0`
- Amazon RDS for PostgreSQL
- Amazon DynamoDB
- AWS Secrets Manager
- GitHub Actions / CI/CD

## Estrutura do repositório

```text
tech-challenge-infra-db/
├── modules/
│   ├── rds-postgres/
│   └── dynamodb-table/
├── services/
│   ├── os-service/
│   ├── execution-service/
│   └── billing-service/
├── docs/
├── doc-archives/
├── README.md
├── SOAT - Fase 4 - Tech challenge.pdf
└── ...
```

## Serviços provisionados

### 1) OS Service

Banco: PostgreSQL (RDS)

- nome do banco: `os_service`
- usuário: `os_service_admin`
- secret: `${project}-${environment}-os-service-db-credentials`

Responsável por:
- abertura e atualização de OS
- consulta de histórico e status
- domínio da ordem de serviço

### 2) Execution Service

Banco: PostgreSQL (RDS)

- nome do banco: `execution_service`
- usuário: `execution_service_admin`
- secret: `${project}-${environment}-execution-service-db-credentials`

Responsável por:
- execução e diagnóstico
- fila de produção
- atualização de status durante reparo e finalização

### 3) Billing Service

Banco: DynamoDB

- tabela criada com prefixo do serviço e GSI por `paymentId`
- policy IAM opcional para acesso da role do serviço

Responsável por:
- geração e envio de orçamento
- registro de pagamento
- atualização do status da OS após aprovação/pagamento

## CI/CD (GitHub Actions)

Cada serviço tem um workflow independente para validar e aplicar a infraestrutura:

- `.github/workflows/db-os-service.yml`
- `.github/workflows/db-execution-service.yml`
- `.github/workflows/db-billing-service.yml`

### Como funcionam

- em `pull_request` para `main`:
  - executa `terraform fmt -check -recursive`
  - `terraform init`
  - `terraform validate`
  - `terraform plan`
  - não aplica nada no AWS
- em `push` para `main`:
  - executa o mesmo fluxo de validação
  - realiza `terraform apply -auto-approve`

Além disso, cada pipeline usa `concurrency` por serviço para evitar que duas execuções do mesmo banco/serviço rodem ao mesmo tempo, e cada workflow dispara apenas quando há alteração no diretório do respectivo serviço ou no módulo compartilhado.

### Secrets necessários

Os workflows usam os seguintes secrets do GitHub Actions:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `TF_BACKEND_BUCKET`
- `VPC_ID`
- `PRIVATE_SUBNET_IDS`
- `EKS_SECURITY_GROUP_ID`

## Requisitos de infraestrutura

Antes de aplicar, você precisa ter:

- VPC existente
- subnets privadas configuradas
- Security Group do EKS (ou dos nodes/pods) com acesso ao banco
- bucket S3 para backend remoto do Terraform
- credenciais AWS com permissão para:
  - RDS
  - DynamoDB
  - Secrets Manager
  - Security Group
  - Subnet Group

## Execução local

Cada microsserviço é provisionado de forma independente.

```bash
# OS Service
cd services/os-service
terraform init
terraform plan
terraform apply

# Execution Service
cd ../execution-service
terraform init
terraform plan
terraform apply

# Billing Service
cd ../billing-service
terraform init
terraform plan
terraform apply
```

Se quiser manter uma configuração por ambiente, configure as variáveis do Terraform conforme o arquivo correspondente em cada serviço.

## Outputs esperados

### OS Service / Execution Service

- `db_endpoint`
- `db_address`
- `db_port`
- `db_name`
- `db_security_group_id`
- `secrets_manager_secret_name`
- `secrets_manager_secret_arn`

### Billing Service

- `table_name`
- `table_arn`
- `payment_index_name`
- `access_policy_arn`

## Como o app deve se conectar

Cada microsserviço deve consumir exclusivamente os recursos do seu próprio banco:

1. obter os outputs do Terraform do serviço
2. buscar os dados do secret no AWS Secrets Manager
3. expor as credenciais para o pod/Deployment do microsserviço via Kubernetes Secret ou via integração do EKS com Secrets Manager
4. garantir que o Security Group do banco libere acesso apenas para o SG do cluster EKS

Nenhum serviço deve acessar diretamente o banco de outro microsserviço.

## Observações importantes

- esta estrutura foi montada para atender ao modelo de microsserviços exigido na Fase 4
- o banco relacional e o banco NoSQL são separados por domínio de negócio
- o repositório é focado em infraestrutura, não em código da aplicação
- a estratégia de Saga Pattern e mensageria precisa ser implementada no código dos serviços e documentada nos READMEs próprios de cada repositório

## Documentação relacionada

-`docs/` — documentação complementar do projeto
