resource "null_resource" "minikube_setup" {
  provisioner "local-exec" {
    command = "minikube delete --profile=lgtm && sleep 2 && minikube start --cpus=max --memory=max --driver=docker --nodes=3 --kubernetes-version=v1.28 --profile=lgtm "
  }

  provisioner "local-exec" {
    command = "minikube addons enable metrics-server --profile=lgtm && minikube addons enable volumesnapshots --profile=lgtm && minikube addons enable csi-hostpath-driver --profile=lgtm && minikube addons disable storage-provisioner --profile=lgtm && minikube addons disable default-storageclass --profile=lgtm"
  }

  provisioner "local-exec" {
    command = "kubectl patch storageclass csi-hostpath-sc -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'"
  }

  provisioner "local-exec" {
    command = "kubectl patch storageclass standard -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete --profile=lgtm"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  depends_on       = [null_resource.minikube_setup]
  name             = "kps"
  namespace        = "kps"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true
  atomic           = true

  values = [file("values/kps.yaml")]
}

resource "helm_release" "promtail" { #https://community.grafana.com/t/promtail-container-crashes-with-an-error-failed-to-make-file-target-manager-too-many-open-files/86248
  depends_on       = [null_resource.minikube_setup, helm_release.kube_prometheus_stack]
  name             = "promtail"
  namespace        = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  create_namespace = true
  atomic           = true

  values = [file("values/promtail.yaml")]
}

resource "helm_release" "grafana" {
  depends_on       = [null_resource.minikube_setup, helm_release.kube_prometheus_stack]
  name             = "grafana"
  namespace        = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  create_namespace = true
  atomic           = true

  values = [file("values/grafana.yaml")]

  set {
    name  = "adminUser"
    value = var.grafana_username
  }

  set {
    name  = "adminPassword"
    value = var.grafana_password
  }
}

resource "helm_release" "loki" {
  depends_on       = [null_resource.minikube_setup, helm_release.kube_prometheus_stack]
  name             = "loki"
  namespace        = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-distributed"
  create_namespace = true
  atomic           = true

  values = [file("values/loki.yaml")]
}

resource "helm_release" "mimir" {
  depends_on       = [null_resource.minikube_setup, helm_release.kube_prometheus_stack]
  name             = "mimir"
  namespace        = "mimir"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "mimir-distributed"
  create_namespace = true
  atomic           = true

  values = [file("values/mimir.yaml")]
}

resource "helm_release" "tempo" {
  depends_on       = [null_resource.minikube_setup, helm_release.kube_prometheus_stack]
  name             = "tempo"
  namespace        = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo-distributed"
  create_namespace = true
  atomic           = true

  values = [file("values/tempo.yaml")]
}
