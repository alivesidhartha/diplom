data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "bastion" {
    name = "bastion"
    hostname = "bastion"
    platform_id = "standard-v1"
    zone = "ru-central1-a"
    
    resources {
        cores =2
        core_fraction = 20
        memory = 1
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
            type = "network-hdd"
            size = 10
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.private_subnet_a.id
        nat = true
    }

    metadata = {
        user-data = file("./cloud-init.yml")
        serial-port-enable = 1
    }

    scheduling_policy { preemptible = false }
}

resource "yandex_compute_instance" "web-a" {
    name = "web-a"
    hostname = "web-a"
    platform_id = "standard-v1"
    zone = "ru-central1-a"

    resources {
        cores = 2
        core_fraction = 20
        memory = 1
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
            type = "network-hdd"
            size = 10
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.private_subnet_a.id
    }

    metadata = {
        user-data = file("./cloud-init.yml")
        serial-port-enable = 1
    }

    scheduling_policy { preemptible = false }
}

resource "yandex_compute_instance" "web-b" {
    name = "web-b"
    hostname = "web-b"
    platform_id = "standard-v1"
    zone = "ru-central1-b"

    resources {
        cores = 2
        core_fraction = 20
        memory = 1
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
            type = "network-hdd"
            size = 10
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.private_subnet_b.id
    }

    metadata = {
        user-data = file("./cloud-init.yml")
        serial-port-enable = 1
    }

    scheduling_policy { preemptible = false }
}

resource "yandex_compute_instance" "monitoring" {
    name = "monitoring"
    hostname = "monitoring"
    platform_id = "standard-v1"
    zone = "ru-central1-a"

    resources {
        cores = 2
        core_fraction = 20
        memory = 4
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
            size = 20
            type = "network-hdd"
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.private_subnet_a.id
        nat = true
    }

    metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = false }

}

  resource "yandex_compute_instance" "logging" {
    name = "logging"
    hostname = "logging"
    platform_id = "standard-v1"
    zone = "ru-central1-a"

    resources {
        cores = 2
        core_fraction = 20
        memory = 4
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
            size = 20
            type = "network-hdd"
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.private_subnet_a.id
    }

    metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
    }

  scheduling_policy { preemptible = false }

  }
  
  resource "yandex_compute_instance" "kibana" {
    name = "kibana"
    hostname = "kibana"
    platform_id = "standard-v1"
    zone = "ru-central1-a"

    resources {
        cores = 2
        core_fraction = 20
        memory = 4
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
            size = 20
            type = "network-hdd"
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.private_subnet_a.id
        nat = true
    }

    metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = false }

}

resource "local_file" "ansible_inventory" {
  filename = "./hosts.ini"
  content = <<EOF
[web]
web-a.ru-central1.internal
web-b.ru-central1.internal

[monitoring]
monitoring.ru-central1.internal

[logging]
logging.ru-central1.internal

[kibana]
kibana.ru-central1.internal

[bastion]
bastion.ru-central1.internal

[all:vars]
ansible_user=user
ansible_ssh_private_key_file=~/.ssh/id_rsa

[web:vars]
ansible_ssh_common_args='-o ProxyJump=user@bastion.ru-central1.internal -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[monitoring:vars]
ansible_ssh_common_args='-o ProxyJump=user@bastion.ru-central1.internal -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[logging:vars]
ansible_ssh_common_args='-o ProxyJump=user@bastion.ru-central1.internal -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[kibana:vars]
ansible_ssh_common_args='-o ProxyJump=user@bastion.ru-central1.internal -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF
}

