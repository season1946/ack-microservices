#---------------------------------------------------------------
# AWS VPC CNI Metrics Helper
# This is using local helm chart
#---------------------------------------------------------------

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

locals {
  addon_name = "ack-apigw"
  namespace = "ack-system"
  
  default_helm_values = [templatefile("${path.module}/helm-values/ack-apigw-values.yaml", {
    region = var.region,
    sa-name        = local.addon_name

  })]

  addon_context = {
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

  helm_config = {
    name        = local.addon_name
    description = "Helm Chart"
    timeout     = "300"
    chart       = "${path.module}/ack-apigw-chart"
    version     = "0.1.7"
    repository  = null
    namespace   = local.namespace
    lint        = false
    values      = local.default_helm_values
  }

  irsa_config = {
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.addon_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    irsa_iam_policies                 = [aws_iam_policy.apigw_fullaccess.arn,aws_iam_policy.apigw_admin.arn]
  }
}

module "helm_addon" {
  source      = "../terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon"
  helm_config = local.helm_config
  irsa_config = local.irsa_config
  addon_context = local.addon_context
  
  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
  
}


data "aws_iam_policy_document" "apigw_fullaccess" {
  statement {
        effect = "Allow"
        actions= [
            "execute-api:Invoke",
            "execute-api:ManageConnections"
        ]
        resources= ["arn:aws:execute-api:*:*:*"]
  }
}

data "aws_iam_policy_document" "apigw_admin" {
  statement {
        effect= "Allow"
        actions= [
            "apigateway:*"
        ]
        resources= ["arn:aws:apigateway:*::/*"]
  }
}

resource "aws_iam_policy" "apigw_fullaccess" {
  name        = "${module.eks_blueprints.eks_cluster_id}-apigw_fullaccess"
  description = "apigw_fullaccess"
  policy      = data.aws_iam_policy_document.apigw_fullaccess.json
  path        = "/"

}

resource "aws_iam_policy" "apigw_admin" {
  name        = "${module.eks_blueprints.eks_cluster_id}-apigw_admin"
  description = "apigw_admin"
  policy      = data.aws_iam_policy_document.apigw_admin.json
  path        = "/"

}
