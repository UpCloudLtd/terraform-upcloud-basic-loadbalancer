variable "name" {
  description = "Load balancer service name"
  type        = string
}

variable "plan" {
  description = "Load balancer service plan"
  type        = string
  default     = "development"
}

variable "zone" {
  description = "Load balancer service zone. Must be the same as private network and servers used with the service"
  type        = string
}

variable "network" {
  description = "UUID of a private network where traffic will be routed. Must be the same as load balancer zone"
  type        = string
}

variable "backend_servers" {
  description = "List of servers that load balancer should distribute the traffic to. Each item in the list should contain the IP address and port, separated with colon (e.g 10.0.0.2:3000)"
  type        = list(string)
}

variable "backend_server_port" {
  description = "Port that will be used by load balancer when sending traffic to each backend server"
  type        = number
}

variable "frontend_port" {
  description = "Port on which the load balancer frontend will listen for requests"
  type        = number
  default     = 443
}

variable "max_server_sessions" {
  description = "Maximum amount of sessions for single server before queueing"
  type        = number
  default     = 1000
}

variable "domains" {
  description = "List of domains that will be used with this load balancer. All of the domains in this list should have a CNAME record set pointing to load balancer DNS name (see `dns_name` output)"
  type        = list(string)
}
