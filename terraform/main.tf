module "network" {
  source    = "./modules/network"
  folder_id = var.folder_id
}

module "vm" {
  source         = "./modules/vm"
  subnet_a_id    = module.network.subnet_a_id
  subnet_b_id    = module.network.subnet_b_id
  image_id       = data.yandex_compute_image.ubuntu_2204_lts.image_id
  folder_id      = var.folder_id
  cloud_init_file = "./files/cloud-init.yml"
}
