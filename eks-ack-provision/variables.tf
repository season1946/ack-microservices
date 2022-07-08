# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = "aws008-preprod-test-eks"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block of the default VPC that hosts the EKS cluster."
  type        = string
  default     = "10.0.0.0/16"
}