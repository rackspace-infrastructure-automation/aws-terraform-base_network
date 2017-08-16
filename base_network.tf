variable "environment" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "availability_zones_count" {
  default = "2"
  type = "string"
  description = "Number of availability Zones to use"
}

variable "instance_tenancy" {
  default = "default"
  type = "string"
  description = "VPC instance tenancy (single tenant - dedicated, multi-tenancy - default"
}

variable "vpc_cidr_range" {
  default = "172.18.0.0/16"
  type = "string"
  description = "The IP Address space used for the VPC in CIDR notation."
}

variable "public_subnets" {
  type = "list"
  description = "Public IP Subnets for AZ1-3."
  default = ["172.18.0.0/22", "172.18.4.0/22", "172.18.8.0/22"]
}

variable "private_subnets" {
  type = "list"
  default = ["172.18.32.0/21", "172.18.40.0/21", "172.18.48.0/21"]
  description = "Private IP Subnets for AZ 1-3."
}

variable "create_vpn" {
  default = false
  description = "Whether to provision a VPN Gateway."
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_range}"
  instance_tenancy = "${var.instance_tenancy}"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags {
    Environment = "${var.environment}"
    Provisioner = "terraform"
    Name = "${format("%s-vpc", var.name)}"
  }
}

resource "aws_internet_gateway" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Environment = "${var.environment}"
    Name = "${var.environment}-IGW"
    Provisioner = "terraform"
  }
}

resource "aws_subnet" "private_subnet" {
  count = "${var.availability_zones_count}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(var.private_subnets, count.index)}"

  tags {
    Name = "${format("%s-private-subnet-az%d", var.name, count.index + 1)}"
    Network = "private"
  }
}

resource "aws_subnet" "public_subnet" {
  count = "${var.availability_zones_count}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(var.public_subnets, count.index)}"

  tags {
    Name = "${format("%s-public-subnet-az%d", var.name, count.index + 1 )}"
    Network = "public"
  }
}

resource "aws_eip" "nat_gw_eip" {
  count = "${var.availability_zones_count}"
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat_gw_eip.*.id, count.index)}"
  count = "${var.availability_zones_count}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
}

resource "aws_route_table" "route_table_private" {
  count = "${var.availability_zones_count}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags {
    Environment = "${var.environment}"
    Name = "${format("%s-PrivateRT-AZ%d", var.name, count.index +1)}"
  }
}

resource "aws_route_table_association" "private_subnet_assocation" {
  count = "${var.availability_zones_count}"
  subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.route_table_private.*.id, count.index)}"
}

resource "aws_route_table" "route_table_public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet.id}"
  }

  tags {
    Environment = "${var.environment}"
    Name = "${format("%s-PublicRT", var.name)}"
  }
}

resource "aws_route_table_association" "public_subnet_assocation" {
  count = "${var.availability_zones_count}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route_table_public.id}"
}

resource "aws_vpn_gateway" "vpn" {
  count = "${var.create_vpn}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${format("%s-VPNGateway", var.name)}"
  }
}

output "private_subnets" {
  value = [ "${aws_subnet.private_subnet.*.id}" ]
}

output "public_subnets" {
  value = [ "${aws_subnet.public_subnet.*.id}" ]
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
