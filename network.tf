resource "yandex_vpc_network" "my_vpc" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "private_subnet_a" {
  name = "site-a"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.my_vpc.id
  v4_cidr_blocks = ["192.168.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "private_subnet_b" {
  name = "site-b"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.my_vpc.id
  v4_cidr_blocks = ["192.168.2.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id      = var.folder_id
  name = "my-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name = "my-route-table"
  network_id = yandex_vpc_network.my_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_alb_target_group" "web_tg" {
  name      = "web-target-group"
  
  target {
    subnet_id = yandex_vpc_subnet.private_subnet_a.id
    ip_address = yandex_compute_instance.web-a.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.private_subnet_b.id
    ip_address = yandex_compute_instance.web-b.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "my_alb_bg" {
  name = "my-backend-group"

  http_backend {
    name             = "my-http-backend"
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.web_tg.id}"]

    healthcheck {
      timeout  = "1s"
      interval = "1s"
      http_healthcheck {
        path = "/"
      }
    }   
  }
}

resource "yandex_alb_http_router" "tf-router" {
  name          = "my-router" 
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "my-virtual-host"
  http_router_id          = yandex_alb_http_router.tf-router.id
  route {
    name                  = "my-route"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.my_alb_bg.id
        timeout           = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "test-balancer" {
  name        = "my-load-balancer"
  network_id  = yandex_vpc_network.my_vpc.id
  #security_group_ids = ["<list_of_security_group_IDs>"]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.private_subnet_a.id
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}
