provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "null_resource" "minikube_setup" {
  provisioner "local-exec" {
    command = "minikube start --cpus=max --memory=max --driver=docker --nodes=3 --kubernetes-version=v1.27.4"
  }

  provisioner "local-exec" {
    command = "minikube addons enable metrics-server && minikube addons enable volumesnapshots && minikube addons enable csi-hostpath-driver && minikube addons disable storage-provisioner && minikube addons disable default-storageclass"
  }

  provisioner "local-exec" {
    command = "kubectl patch storageclass csi-hostpath-sc -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete"
  }
}

variable "grafana_username" {
  description = "Username for Grafana"
  type        = string
  default     = "admin"
}

variable "grafana_password" {
  description = "Password for Grafana"
  type        = string
  default     = "admin"
}

resource "helm_release" "kube_prometheus_stack" {
  depends_on       = [null_resource.minikube_setup]
  name             = "kps"
  namespace        = "kps"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true
  atomic           = true

  values = [file("values_kps.yaml")]
}

resource "helm_release" "promtail" {
  depends_on       = [null_resource.minikube_setup, helm_release.kube_prometheus_stack]
  name             = "promtail"
  namespace        = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  create_namespace = true
  atomic           = true

  values = [file("values_promtail.yaml")]
}

resource "helm_release" "lgtm" {
  depends_on       = [null_resource.minikube_setup, helm_release.kube_prometheus_stack]
  name             = "lgtm"
  namespace        = "lgtm"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "lgtm-distributed"
  create_namespace = true
  atomic           = true

  values = [file("values_lgtm.yaml")]

  set {
    name  = "grafana.adminUser"
    value = var.grafana_username
  }

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }

}

output "lgtm_grafana_port_forward_command" {
  description = "Command to port forward the lgtm-grafana service"
  value       = "kubectl port-forward services/lgtm-grafana 8080:80 -n lgtm"
}

output "grafana_username" {
  description = "Grafana Username"
  value       = var.grafana_username
}

output "grafana_password" {
  description = "Grafana Password"
  value       = var.grafana_password
}
