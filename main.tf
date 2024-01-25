terraform {
  required_version = ">= 1.0.0"

  cloud {
    organization = "fiap-pos-tech"

    workspaces {
      name = "payment-service"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33.0"
    }

    mysql = {
      source  = "bluemill/mysql"
      version = "1.11.0"
    }
  }
}