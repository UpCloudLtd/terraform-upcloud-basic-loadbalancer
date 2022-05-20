terraform {
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 2.4"
    }
  }
}

provider "upcloud" {}

resource "upcloud_network" "network" {
  name = "my_network"
  zone = "pl-waw1"

  ip_network {
    family  = "IPv4"
    address = "10.0.1.0/24"
    dhcp    = true
  }
}

resource "upcloud_server" "webservers" {
  count    = 3
  hostname = "webserver${count.index}"
  title    = "webserver_${count.index}"
  zone     = "pl-waw1"
  plan     = "1xCPU-2GB"

  template {
    storage = "Ubuntu Server 20.04 LTS (Focal Fossa)"
    size    = 25
  }

  network_interface {
    type = "utility"
  }

  network_interface {
    type    = "private"
    network = upcloud_network.network.id
  }
}

module "load_balancer" {
  source = "UpCloudLtd/basic-loadbalancer/upcloud"

  name                = "my_loadbalancer"
  zone                = "pl-waw1"
  network             = upcloud_network.network.id
  backend_servers     = [for v in upcloud_server.webservers : v.network_interface.1.ip_address]
  backend_server_port = 3000
  domains             = ["my.domain.net"]
}

output "lb_url" {
  value = module.load_balancer.dns_name
}
