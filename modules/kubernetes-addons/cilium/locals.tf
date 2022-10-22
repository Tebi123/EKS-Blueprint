locals {
  name = "cilium"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://helm.cilium.io/"
    version     = "1.12.3"
    namespace   = "kube-system"
    values      = local.default_helm_values
    description = "cilium helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml.tmpl", {
    enable_wireguard = var.enable_wireguard
  })]

  argocd_gitops_config = {
    enable = true
  }
}
