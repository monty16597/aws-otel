terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      "Project"     = local.project_name
      "Environment" = local.environment_name
    }
  }
}
