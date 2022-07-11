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
  
  depends_on = [
    module.helm_addon
  ]
}




data "aws_iam_policy" "dynamo_fullaccess" {
   name = "AmazonDynamoDBFullAccess"
}


# create irsa for api app read and write dynamodb 
resource "aws_iam_role" "dynamo-rw_role" {
  name = "${local.cluster_name}-dynamo-rw-irsa"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks_blueprints.eks_oidc_provider_arn}"
        }
        
      },
    ]
  })
  
  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
               "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}
