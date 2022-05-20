# Rest of the configuration omitted for brevity

module "load_balancer" {
  source = "UpCloudLtd/basic-loadbalancer/upcloud"

  name            = "my_loadbalancer"
  zone            = "pl-waw1"
  network         = upcloud_network.my_network.id
  backend_servers = ["10.0.1.3", "10.0.1.4", "10.0.1.5"]
  domains         = ["my.domain.net"]
}

resource "upcloud_loadbalancer_frontend_rule" "some_rule" {
  frontend = module.load_balancer.frontend_id
  name     = "some_rule"
  priority = 10

  matchers {
    url_param {
      method = "exact"
      name   = "secret"
      value  = "1"
    }
  }

  actions {
    http_redirect {
      location = "/super-secret-place"
    }
  }
}
