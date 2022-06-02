terraform {
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 2.4"
    }
  }
}

provider "upcloud" {}

locals {
  prefix = "lb-module-basic-example-"
}

resource "upcloud_network" "network" {
  name = "${local.prefix}net"
  zone = "pl-waw1"

  ip_network {
    family  = "IPv4"
    address = "10.0.1.0/24"
    dhcp    = true
  }
}

resource "upcloud_server" "webservers" {
  count    = 3
  hostname = "${local.prefix}server-${count.index}"
  title    = "${local.prefix}server-${count.index}"
  zone     = "pl-waw1"
  plan     = "1xCPU-1GB"

  # Use user-data script to install and launch http server on start
  metadata  = true
  user_data = file("${path.module}/user-data-script.sh")

  template {
    storage = "Ubuntu Server 20.04 LTS (Focal Fossa)"
    size    = 25
    title   = "${local.prefix}storage-${count.index}"
  }

  # Required to have internet access when installing httpd on launch
  network_interface {
    type = "public"
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

  name                = "${local.prefix}lb"
  zone                = "pl-waw1"
  network             = upcloud_network.network.id
  backend_servers     = [for v in upcloud_server.webservers : v.network_interface.2.ip_address]
  backend_server_port = 80

  # To enable TLS on the frontend:
  # - Uncomment and replace example.com with your domain
  # - Change frontend port from 80 to 443

  # domains       = ["example.com"]
  frontend_port = 80
}

output "lb_url" {
  value = module.load_balancer.dns_name
}
