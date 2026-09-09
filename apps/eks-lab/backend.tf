terraform {
  backend "s3" {
    key = "eks-lab/terraform.tfstate"
  }
}
