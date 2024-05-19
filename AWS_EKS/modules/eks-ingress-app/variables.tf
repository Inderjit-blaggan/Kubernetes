
##############################################
# Variables
##############################################


# Input Variables - Placeholder file
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"  
}


variable "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  type = string
}

variable "domain_name" {
  description = "The domain name used for ACM"
  type = string
}