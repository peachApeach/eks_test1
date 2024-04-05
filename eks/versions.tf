terraform {
  required_version = ">= 1.0"

  backend s3 {
    bucket         = "smartscoretfstate" # S3 버킷 이름
    key            = "eks/terraform.tfstate" # tfstate 저장 경로
    region         = "ap-northeast-2"
    dynamodb_table = "smartscore-eks-tfstate-lock" # dynamodb table 이름
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.17.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.5.1"
    }
  }
}