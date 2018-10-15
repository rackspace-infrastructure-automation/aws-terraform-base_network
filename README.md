# Base Network Module

## Usage
```hcl
module "base_network" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-base_network"

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tags | Additional tags to be added to the VPC. | map | `<map>` | no |
| availability_zones_count | Number of Availability Zones to use | string | `2` | no |
| environment | The Environment this VPC is being deployed into (prod, dev, test, etc) | string | - | yes |
| instance_tenancy | VPC Instance Tenancy (single tenant - dedicated, multi-tenancy - default) | string | `default` | no |
| name | The name of the VPC | string | - | yes |
| private_subnets | IP Address Ranges in CIDR Notation for Private Subnets in AZ 1-3. | list | `<list>` | no |
| public_subnets | IP Address Ranges in CIDR Notation for Public Subnets in AZ1-3. | list | `<list>` | no |
| transit_vpc | Enable TransitVPC on this VGW | string | `false` | no |
| vpc_cidr_range | The IP Address space used for the VPC in CIDR notation. | string | `172.18.0.0/16` | no |
| vpn_gateways | Number of VPN Gateways to provision | string | `0` | no |


## Outputs

| Name | Description |
|------|-------------|
| nat_ips |  |
| private_route_table_ids | List of IDs of private route tables |
| private_subnets |  |
| public_route_table_ids | List of IDs of public route tables |
| public_subnets |  |
| vpc_id |  |
| vpn_gateway_ids | List of IDs of VPN gateways |
