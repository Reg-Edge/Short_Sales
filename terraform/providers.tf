# providers.tf
# AWS provider configuration (region default: ap-south-1)
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region  = var.region
  profile = "re_prabhakaran"
}
