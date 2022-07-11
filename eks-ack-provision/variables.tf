# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster"
  type        = string
 
}

variable "region" {
  type        = string
  description = "AWS region"
  
}

variable "vpc_cidr" {
  description = "The CIDR block of the default VPC that hosts the EKS cluster."
  type        = string

}