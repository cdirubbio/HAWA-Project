terraform {
  cloud {
    organization = var.HCP_Org
    workspaces {
      name = "HAWA-PROJECT"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}