terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Definição de qual provider será utilizado
provider "aws" {
  region = "us-west-2"
}