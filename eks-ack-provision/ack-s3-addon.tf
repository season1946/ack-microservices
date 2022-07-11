#---------------------------------------------------------------
# AWS VPC CNI Metrics Helper
# This is using local helm chart
#---------------------------------------------------------------


locals {
  s3_name = "ack-s3"
  s3_namespace  = "ack-system"
  
  s3_default_helm_values = [templatefile("${path.module}/helm-values/ack-s3-values.yaml", {
    region = var.region,
    sa-name        = local.s3_name

  })]

  s3_addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.cluster.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = var.region
    eks_cluster_id                 = module.eks_blueprints.eks_cluster_id
    eks_oidc_issuer_url            = module.eks_blueprints.oidc_provider
    eks_oidc_provider_arn          = module.eks_blueprints.eks_oidc_provider_arn
    tags                           = {}
  }

  s3_helm_config = {
    name        = local.s3_name
    description = "Helm Chart"
    timeout     = "300"
    chart       = "${path.module}/ack-s3-chart"
    version     = "0.1.2"
    repository  = null
    namespace   = local.s3_namespace
    lint        = false
    values      = local.s3_default_helm_values
  }

  s3_irsa_config = {
    kubernetes_namespace              = local.s3_namespace
    kubernetes_service_account        = local.s3_name
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    irsa_iam_policies                 = [data.aws_iam_policy.s3_fullaccess.arn]
  }
}

module "s3_helm_module" {
  source      = "../terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon"
  helm_config = local.s3_helm_config
  irsa_config = local.s3_irsa_config
  addon_context = local.s3_addon_context
  
  depends_on = [
    module.helm_addon
  ]
}




data "aws_iam_policy" "s3_fullaccess" {
   name = "AmazonS3FullAccess"
}


