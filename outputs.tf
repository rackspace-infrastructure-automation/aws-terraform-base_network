output "private_subnets" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "public_subnets" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "nat_ips" {
  value = ["${aws_eip.nat_gw_eip.*.public_ip}"]
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = ["${aws_route_table.route_table_public.*.id}"]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = ["${aws_route_table.route_table_private.*.id}"]
}

output "vpn_gateway_ids" {
  description = "List of IDs of VPN gateways"
  value       = ["${aws_vpn_gateway.vpn.*.id}"]
}
