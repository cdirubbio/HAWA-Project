terraform {
  cloud {
    organization = "cdirubbs-demo-organization"
    workspaces {
      name = "HAWA-PROJECT"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}