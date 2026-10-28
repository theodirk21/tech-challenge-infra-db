terraform {
  # O bucket é informado no init: terraform init -backend-config="bucket=<BUCKET>"
  # Cada serviço tem a sua própria key, portanto o seu próprio state e lock.
  backend "s3" {
    key          = "infra-db/execution-service.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
