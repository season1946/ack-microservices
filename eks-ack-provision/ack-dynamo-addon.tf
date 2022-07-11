#---------------------------------------------------------------
# AWS VPC CNI Metrics Helper
# This is using local helm chart
#---------------------------------------------------------------


locals {
  dynamo_name = "ack-dynamo"
  dynamo_namespace  = "ack-system"
  
  dynamo_default_helm_values = [templatefile("${path.module}/helm-values/ack-dynamo-values.yaml", {
    region = var.region,
    sa-name        = local.dynamo_name

  })]

  dynamo_addon_context = {
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

  dynamo_helm_config = {
    name        = local.dynamo_name
    description = "Helm Chart"
    timeout     = "300"
    chart       = "${path.module}/ack-dynamo-chart"
    version     = "0.1.2"
    repository  = null
    namespace   = local.dynamo_namespace
    lint        = false
    values      = local.dynamo_default_helm_values
  }

  dynamo_irsa_config = {
    kubernetes_namespace              = local.dynamo_namespace
    kubernetes_service_account        = local.dynamo_name
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    irsa_iam_policies                 = [data.aws_iam_policy.dynamo_fullaccess.arn]
  }
}

module "dynamo_helm_module" {
  source      = "../terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon"
  helm_config = local.dynamo_helm_config
  irsa_config = local.dynamo_irsa_config
  addon_context = local.dynamo_addon_context
}




data "aws_iam_policy" "dynamo_fullaccess" {
   name = "AmazonDynamoDBFullAccess"
}



# resource "aws_iam_policy" "dynamo_fullaccess" {
#   name        = "${var.eks_cluster_id}-dynamo_fullaccess"
#   description = "dynamo_fullaccess"
#   policy      = data.aws_iam_policy_document.dynamo_fullaccess.json

# }
