# TerraformのProviderの設定を記述する。

# Terraformの最低バージョンなどの制約を記述
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Providerの設定
# AWSの認証設定
# AWSのどのリージョンのAPIに接続するか
# などを記述する。
provider "aws" {
  region = var.region

  # 全リソースに強制的に付与するタグ
  default_tags {
    tags = {
      owner = var.owner_name
    }
  }
}

# k8sプロバイダ
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
