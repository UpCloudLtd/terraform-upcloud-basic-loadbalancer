terraform {
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 5.23"
    }
  }
}

resource "upcloud_loadbalancer" "main" {
  configured_status = "started"
  name              = var.name
  plan              = var.plan
  zone              = var.zone

  networks {
    name = "public"
    family = "IPv4"
    type = "public"
  }

  networks {
    name = "private"
    family = "IPv4"
    network = var.network
    type = "private"
  }
}

resource "upcloud_loadbalancer_backend" "main" {
  loadbalancer = upcloud_loadbalancer.main.id
  name         = "main"
}

resource "upcloud_loadbalancer_static_backend_member" "main" {
  count        = length(var.backend_servers)
  backend      = upcloud_loadbalancer_backend.main.id
  name         = "member_${count.index}"
  ip           = var.backend_servers[count.index]
  port         = var.backend_server_port
  max_sessions = var.max_server_sessions
  enabled      = true
  weight       = 100
}

resource "upcloud_loadbalancer_frontend" "main" {
  loadbalancer         = upcloud_loadbalancer.main.id
  name                 = "main"
  mode                 = "http"
  port                 = var.frontend_port
  default_backend_name = upcloud_loadbalancer_backend.main.name

  networks {
    name = upcloud_loadbalancer.main.networks[0].name
  }
}

resource "upcloud_loadbalancer_dynamic_certificate_bundle" "main" {
  count     = length(var.domains) > 0 ? 1 : 0
  name      = "main"
  hostnames = var.domains
  key_type  = "rsa"
}

resource "upcloud_loadbalancer_frontend_tls_config" "main" {
  count              = length(var.domains) > 0 ? 1 : 0
  frontend           = upcloud_loadbalancer_frontend.main.id
  name               = "main"
  certificate_bundle = upcloud_loadbalancer_dynamic_certificate_bundle.main[count.index].id
}
