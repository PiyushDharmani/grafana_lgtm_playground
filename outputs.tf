output "lgtm_grafana_port_forward_command" {
  description = "Command to port forward the lgtm-grafana service"
  value       = "kubectl port-forward services/grafana 8080:80 -n grafana"
}

output "grafana_username" {
  description = "Grafana Username"
  value       = var.grafana_username
}

output "grafana_password" {
  description = "Grafana Password"
  value       = var.grafana_password
}
