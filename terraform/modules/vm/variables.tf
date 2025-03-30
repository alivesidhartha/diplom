variable "subnet_a_id" {
  type = string
}

variable "subnet_b_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "cloud_init_file" {
  type    = string
  default = "./files/cloud-init.yml"
}
