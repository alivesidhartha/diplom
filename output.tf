output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_ips" {
  value = [yandex_compute_instance.web-a.network_interface[0].ip_address,
           yandex_compute_instance.web-b.network_interface[0].ip_address]
}

output "logging_ip" {
  value = yandex_compute_instance.logging.network_interface[0].ip_address
}

output "monitoring_ip" {
  value = yandex_compute_instance.monitoring.network_interface[0].ip_address
}

output "kibana_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].ip_address
}
