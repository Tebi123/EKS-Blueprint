locals {
  name            = "karpenter"
  service_account = try(var.helm_config.service_account, "karpenter")
  set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]
  karpenter_sqs_queue_arn = var.karpenter_sqs_queue_arn != null ? var.karpenter_sqs_queue_arn : "arn:aws:sqs:${var.addon_context["aws_region_name"]}:${var.addon_context["aws_caller_identity_account_id"]}:${var.addon_context["eks_cluster_id"]}"

  # https://github.com/aws/karpenter/blob/main/charts/karpenter/Chart.yaml
  helm_config = merge(
    {
      name       = local.name
      chart      = local.name
      repository = "oci://public.ecr.aws/karpenter"
      version    = "v0.19.1"
      namespace  = local.name
      values = [
        <<-EOT
          settings:
            aws:
              clusterName: ${var.addon_context.eks_cluster_id}
              clusterEndpoint: ${var.addon_context.aws_eks_cluster_endpoint}
              defaultInstanceProfile: ${var.node_iam_instance_profile}
        EOT
      ]
      description = "karpenter Helm Chart for Node Autoscaling"
    },
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.karpenter.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account
    controllerClusterEndpoint = var.addon_context.aws_eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
}
