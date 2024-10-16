terraform {
  required_version = "1.9.8"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.3.1"
    }
  }
}

provider "github" {}
