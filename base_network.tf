/*
  Base Network Module
  Fanatical Support for Amazon Web Services
  Rackspace
*/

## Variables

# Descriptive name of the Environment to add to tags (should make sense to humans)
variable "environment" {
  type = "string"
  description = "The Environment this VPC is being deployed into (prod, dev, test, etc)"
}
# Name to give to the VPC and associated resources
variable "name" {
  type = "string"
  description = "The name of the VPC"
}
# Number of AZs to create
variable "availability_zones_count" {
  default = "2"
  type = "string"
  description = "Number of Availability Zones to use"
}
# Instance Tenancy (can be dedicated or default)
variable "instance_tenancy" {
  default = "default"
  type = "string"
  description = "VPC Instance Tenancy (single tenant - dedicated, multi-tenancy - default)"
}
# The CIDR Range for the entire VPC
variable "vpc_cidr_range" {
  default = "172.18.0.0/16"
  type = "string"
  description = "The IP Address space used for the VPC in CIDR notation."
}
# The CIDR Ranges for the Public Subnets
variable "public_subnets" {
  type = "list"
  description = "IP Address Ranges in CIDR Notation for Public Subnets in AZ1-3."
  default = ["172.18.0.0/22", "172.18.4.0/22", "172.18.8.0/22"]
}
# The CIDR Ranges for the Private Subnets
variable "private_subnets" {
  type = "list"
  default = ["172.18.32.0/21", "172.18.40.0/21", "172.18.48.0/21"]
  description = "IP Address Ranges in CIDR Notation for Private Subnets in AZ 1-3."
}
# Number of VPN Gateways to create
variable "vpn_gateways" {
  default = "0"
  description = "Number of VPN Gateways to provision"
}

## Resources

### VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_range}"
  instance_tenancy = "${var.instance_tenancy}"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags {
    Environment = "${var.environment}"
    Provisioner = "rackspace"
    Name = "${var.name}"
  }
}

### Internet Gateway
resource "aws_internet_gateway" "internet" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Environment = "${var.environment}"
    Name = "${var.name}-IGW"
    Provisioner = "rackspace"
  }
}

### Private Subnets
# Loop over this as many times as necessary to create the correct number of Private Subnets
resource "aws_subnet" "private_subnet" {
  count = "${var.availability_zones_count}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${element(var.private_subnets, count.index)}"

  tags {
    Environment = "${var.environment}"
    Name = "${format("%s-private-subnet-az%d", var.name, count.index + 1)}"
    Network = "private"
    Provisioner = "rackspace"
  }
}

### Public Subnets
# Loop over this as many times as necessary to create the correct number of Public Subnets
resource "aws_subnet" "public_subnet" {
  count = "${var.availability_zones_count}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${element(var.public_subnets, count.index)}"

  tags {
    Environment = "${var.environment}"
    Name = "${format("%s-public-subnet-az%d", var.name, count.index + 1 )}"
    Network = "public"
    Provisioner = "rackspace"
  }
}

### Elastic IPs
# Need one per AZ for the NAT Gateways
resource "aws_eip" "nat_gw_eip" {
  count = "${var.availability_zones_count}"
  vpc = true
}

### NAT Gateways
# Loops as necessary to create one per AZ in the Public Subnets, and associate the provisioned Elastic IP
resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat_gw_eip.*.id, count.index)}"
  count = "${var.availability_zones_count}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
}

### Private Subnet Route Tables
# Routes traffic destined for `0.0.0.0/0` to the NAT Gateway in the same AZ
resource "aws_route_table" "route_table_private" {
  count = "${var.availability_zones_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags {
    Environment = "${var.environment}"
    Name = "${format("%s-PrivateRT-AZ%d", var.name, count.index +1)}"
    Provisioner = "rackspace"
  }
}

### Private Subnet Route Table Associations
resource "aws_route_table_association" "private_subnet_assocation" {
  count = "${var.availability_zones_count}"
  subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.route_table_private.*.id, count.index)}"
}

### Public Route Tables
# Routes traffic destined for `0.0.0.0/0` to the Internet Gateway for the VPC
resource "aws_route_table" "route_table_public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet.id}"
  }

  tags {
    Environment = "${var.environment}"
    Name = "${format("%s-PublicRT", var.name)}"
    Provisioner = "rackspace"
  }
}

### Public Route Table Associations
resource "aws_route_table_association" "public_subnet_assocation" {
  count = "${var.availability_zones_count}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route_table_public.id}"
}

### VPN Gateways
resource "aws_vpn_gateway" "vpn" {
  count = "${var.create_vpn}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${format("%s-VPNGateway", var.name)}"
    Provisioner = "rackspace"
  }
}

## Outputs

output "private_subnets" {
  value = [ "${aws_subnet.private_subnet.*.id}" ]
}

output "public_subnets" {
  value = [ "${aws_subnet.public_subnet.*.id}" ]
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
