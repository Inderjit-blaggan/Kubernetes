###########################################
# LOCAL VALUES
############################################
# Define Local Values in Terraform
locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${var.business_divsion}-${var.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
  #eks_cluster_name = "${data.terraform_remote_state.eks.outputs.cluster_id}"  
  
} 



##############################################
# Variables
##############################################


# Input Variables - Placeholder file
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-2"  
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "sap"
}


#variable "oidc_provider_arn" {
#  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
#  type = string
#}

variable "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  type = string
}

#variable "vpc_id" {
#  description = "VPC Id"
#  type = string
#}