## COMMON

variable "pj" {
  type    = string
  default = "rag_compass"

}

variable "owner_name" {
  type    = string
  default = "ai-team"
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

## NETWORK

# VPC
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Subnet
# CIDRとの関係性を管理するためMAPで定義
variable "subnet" {
  type = map(object({
    az   = string
    cidr = string
  }))
  default = {
    public_a = {
      az   = "a"
      cidr = "10.0.10.0/24"
    }
    private_a = {
      az   = "a"
      cidr = "10.0.11.0/24"
    }
    public_c = {
      az   = "c"
      cidr = "10.0.20.0/24"
    }
    private_c = {
      az   = "c"
      cidr = "10.0.21.0/24"
    }
  }
}

variable "cluster_name" {
  type    = string
  default = "sample-eks"
}
