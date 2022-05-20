output "id" {
  value = upcloud_loadbalancer.main.id
}

output "dns_name" {
  value = upcloud_loadbalancer.main.dns_name
}

output "backend_name" {
  value = upcloud_loadbalancer_backend.main.name
}

output "backend_id" {
  value = upcloud_loadbalancer_backend.main.id
}

output "frontend_name" {
  value = upcloud_loadbalancer_frontend.main.name
}

output "frontend_id" {
  value = upcloud_loadbalancer_frontend.main.id
}
