# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.12"
      version = ">= 4.65"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      #version = "~> 2.11"
      version = ">= 2.20"
    }    
  }
  # Adding Backend as S3 for Remote State Storage
#   backend "s3" {
#     bucket = "terraform-on-aws-eks"
#     key    = "dev/aws-lbc-ingress/terraform.tfstate"
#     region = "us-east-1" 

#     # For State Locking
#     dynamodb_table = "dev-aws-lbc-ingress"    
#   }    
}


# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "example" {
  name = var.cluster_id
}

# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id 
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
