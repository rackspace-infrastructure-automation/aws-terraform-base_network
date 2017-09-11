# Base Network Module

## Usage
```hcl
module "base_network" {
  source = "git@github.com:rackspace-infrastructure-automation/rackspace-aws-terraform//base_network"

  environment = "REQUIRED_EDIT_ME"
  name = "REQUIRED_EDIT_ME"
  availability_zones_count = "2"
  instance_tenancy = "default"
  vpc_cidr_range = "172.18.0.0/16"
  public_subnets = ["172.18.0.0/22", "172.18.4.0/22", "172.18.8.0/22"]
  private_subnets = ["172.18.32.0/21", "172.18.40.0/21", "172.18.48.0/21"]
  vpn_gateways = "0"
}
```
