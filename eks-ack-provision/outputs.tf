output "vpc_private_subnet_cidr" {
  description = "VPC private subnet CIDR"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "vpc_public_subnet_cidr" {
  description = "VPC public subnet CIDR"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_IDs" {
  description = "VPC private_subnets"
  value       = module.vpc.private_subnets
}


output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_oidc_issuer_url" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_oidc_issuer_url
}

output "oidc_provider" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_oidc_provider_arn
}

output "eks_managed_nodegroups" {
  description = "EKS managed node groups"
  value       = module.eks_blueprints.managed_node_groups
}

output "eks_managed_nodegroup_ids" {
  description = "EKS managed node group ids"
  value       = module.eks_blueprints.managed_node_groups_id
}

output "eks_managed_nodegroup_arns" {
  description = "EKS managed node group arns"
  value       = module.eks_blueprints.managed_node_group_arn
}

output "eks_managed_nodegroup_role_name" {
  description = "EKS managed node group role name"
  value       = module.eks_blueprints.managed_node_group_iam_role_names
}

output "eks_managed_nodegroup_status" {
  description = "EKS managed node group status"
  value       = module.eks_blueprints.managed_node_groups_status
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

# Region used for Terratest
output "region" {
  value       = local.region
  description = "AWS region"
}

output "apigw_vpclink_id" {
  description = "API Gataway vpclink id"
  value       = resource.aws_apigatewayv2_vpc_link.vpclink.id
}
