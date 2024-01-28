
# Configuração do backend para armazenar o estado do terraform no S3
terraform {
  backend "s3" {
    bucket = "bucket-fiap-soat1-grupo56-remote-state"
    key    = "fasteats-aplicacao-pagamento/terraform.tfstate"
    region = "us-east-1"
  }
}