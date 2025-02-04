terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = var.region_name
  default_tags {
    tags = {
      "Project"     = var.project_name
      "Environment" = var.environment_name
      "Region"      = var.region_name
      "Owner"       = var.resource_owner
    }
  }
}
