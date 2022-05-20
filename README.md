# UpCloud Basic Loadbalancer

Terraform module which creates a basic load balancer setup with with automatic SSL certificate.

## Usage
```hcl
module "load_balancer" {
  source = "UpCloudLtd/basic-loadbalancer/upcloud"

  name                = "my_loadbalancer"
  zone                = "pl-waw1"
  network             = upcloud_network.my_network.id
  backend_servers     = ["10.0.1.3", "10.0.1.4", "10.0.1.5"]
  backend_server_port = 3000
  domains             = ["my.domain.net"]
}
```
