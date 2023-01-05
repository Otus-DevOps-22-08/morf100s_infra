resource "yandex_lb_target_group" "foo" {
  name      = "my-target-group"
  folder_id = var.folder_id

  dynamic "target" {
    for_each = yandex_compute_instance.app[*].network_interface.0.ip_address
    content {
      subnet_id = var.subnet_id
      address   = target.value
    }
  }

}

resource "yandex_lb_network_load_balancer" "foo" {
  name      = "my-network-load-balancer"
  folder_id = var.folder_id

  listener {
    name        = "my-listener"
    port        = 80
    target_port = 9292
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.foo.id

    healthcheck {
      name = "http"
      http_options {
        port = 9292
        path = "/"
      }
    }
  }
}
