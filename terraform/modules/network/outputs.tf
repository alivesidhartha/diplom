output "network_id" {
  value = yandex_vpc_network.my_vpc.id
}

output "subnet_a_id" {
  value = yandex_vpc_subnet.private_subnet_a.id
}

output "subnet_b_id" {
  value = yandex_vpc_subnet.private_subnet_b.id
}

output "route_table_id" {
  value = yandex_vpc_route_table.rt.id
}

output "gateway_id" {
  value = yandex_vpc_gateway.nat_gateway.id
}
