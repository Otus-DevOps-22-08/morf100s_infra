terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.84.0"
    }
  }
}

resource "yandex_compute_instance" "app" {
  name = "reddit-app"

  labels = {
    tags = "reddit-app"
  }

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
#    subnet_id = yandex_vpc_subnet.app-subnet.id
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

}
