# This test deploys a VPC with no NAT Gateways (nat_gateways=false)

provider "aws" {
  region = "us-east-2"
}

resource "random_string" "vpc_rstring" {
  length  = 18
  upper   = false
  special = false
}

module "base_network" {
  source = "../../module"

  vpc_name            = "${format("%s-%s" "Test-VPC", "random_string.vpc_rstring")}"
  custom_azs          = ["us-east-2a", "us-east-2b"]
  cidr_range          = "172.18.0.0/16"
  public_cidr_ranges  = ["172.18.168.0/22", "172.18.172.0/22"]
  private_cidr_ranges = ["172.18.0.0/21", "172.18.8.0/21"]
  environment         = "Test"

  nat_gateways = "false"
}
