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
  region  = var.region
  profile = "default" # .aws/credentialのdefaultを使用

  # 全リソースに強制的に付与するタグ
  default_tags {
    tags = {
      owner = var.owner_name
    }
  }
}
