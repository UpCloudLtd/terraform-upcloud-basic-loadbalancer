terraform {
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 2.4"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "upcloud" {}
provider "cloudflare" {}

variable "subdomain_name" {
  type        = string
  description = "Subdomain name that will be used for the test. Should be a unique(ish) value to prevent collisions when running this test in multiple places"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "ID of the cloudflare zone that will be used to setup subdomain with CNAME record pointing at load balancer URL"
}

data "cloudflare_zone" "domain" {
  zone_id = var.cloudflare_zone_id
}

locals {
  full_domain_name = "${var.subdomain_name}.${data.cloudflare_zone.domain.name}"
}

resource "upcloud_network" "network" {
  name = "tf_basic_loadbalancer_module"
  zone = "pl-waw1"

  ip_network {
    family  = "IPv4"
    address = "10.0.100.0/24"
    dhcp    = true
  }
}

resource "upcloud_server" "webservers" {
  count    = 2
  hostname = "test${count.index}"
  title    = "tf_basic_loadbalancer_module_${count.index}"
  zone     = "pl-waw1"
  plan     = "1xCPU-2GB"

  user_data = <<EOF
#!/bin/bash
echo "Hello, Test!" > index.html
nohup busybox httpd -f -p 3000 &
EOF

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
  source = "../../"

  name                = "tf_basic_loadbalancer_module"
  zone                = "pl-waw1"
  network             = upcloud_network.network.id
  backend_servers     = [for v in upcloud_server.webservers : v.network_interface.1.ip_address]
  backend_server_port = 3000
  domains             = [local.full_domain_name]
}

resource "upcloud_loadbalancer_frontend_rule" "return_rule" {
  name     = "return_rule"
  frontend = module.load_balancer.frontend_id
  priority = 10

  matchers {
    url_param {
      method = "exact"
      name   = "test"
      value  = "1"
    }
  }

  actions {
    http_return {
      content_type = "text/plain"
      payload      = base64encode("Returned!")
      status       = 200
    }
  }
}

resource "cloudflare_record" "lb_dns_record" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.subdomain_name
  value   = module.load_balancer.dns_name
  type    = "CNAME"
  ttl     = 1
}

output "url" {
  value = "https://${local.full_domain_name}"
}
