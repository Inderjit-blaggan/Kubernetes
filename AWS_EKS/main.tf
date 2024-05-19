locals {
  name   = "EKS-${replace(basename(path.cwd), "_", "-")}"
  region = "us-east-2"


  tags = {
    Environment = "dev"
    CommonTag   = "${local.name}-common-tag"
  }
}

module "vpc" {
  source                  = "./modules/vpc"
  name                    = local.name
  vpc_cidr                = var.vpc_cidr
  oidc_provider_arn       = module.eks.oidc_provider_arn
  eks_managed_node_groups = module.eks.eks_managed_node_groups

}

module "eks" {
  source          = "./modules/eks"
  name            = local.name
  cluster_version = "1.27"
  aws_auth_roles  = var.aws_auth_roles
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  intra_subnets   = module.vpc.intra_subnets
}



##################################################################
# Install EBS CSI driver Self Managed
################################################################

#module "ebs-csi-self-managed-addon" {
#  source          = "./modules/ebs-csi-self-managed-addon"
#  aws_region      = local.region
#  oidc_provider_arn = module.eks.oidc_provider_arn
#  cluster_id = module.eks.cluster_name
#  vpc_id          = module.vpc.vpc_id
#}


##################################################################
# Install EBS CSI driver EKS Managed
################################################################

module "ebs-csi-eks-managed-addon" {
  source          = "./modules/ebs-csi-eks-managed-addon"
  aws_region      = local.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_id = module.eks.cluster_name
  vpc_id          = module.vpc.vpc_id
}

##################################################################
# Install Cluster Autoscaler EKS Managed
################################################################

module "ebs-cluster_autoscaler-managed-addon" {
  source          = "./modules/cluster-autoscaler"
  aws_region      = local.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_id = module.eks.cluster_name
  vpc_id          = module.vpc.vpc_id
}



##################################################################
# Install AWS ALB controller
################################################################

module "eks-addon" {
  source          = "./modules/eks-addons"
  aws_region      = local.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_id = module.eks.cluster_name
  vpc_id          = module.vpc.vpc_id
}

##################################################################
# Install AWS External controller (route 53)
################################################################


module "eks-external-dns" {
  source          = "./modules/eks-external-dns-addon"
  aws_region      = local.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_id = module.eks.cluster_name
  vpc_id          = module.vpc.vpc_id
}



##################################################################
# MYSQL APP to test EBS-CSI
################################################################

module "eks-csi-ums-webapp" {
  source          = "./modules/ebs-csi-ums-webapp"
  aws_region      = local.region
  cluster_id = module.eks.cluster_name
}




##################################################################
# Ingress APP
################################################################


module "eks-ingress-app" {
 source          = "./modules/eks-ingress-app"
 aws_region      = local.region
 cluster_id = module.eks.cluster_name
 domain_name = "*.teams.systems"
}





################################################################################
# argocd helm deployment
################################################################################

module "argo_application" {
  # source = "lablabs/eks-argocd/aws"
  source = "./modules/eks-argocd-helm"

  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn

  helm_force_update = true

  # enabled           = true
  # argo_enabled      = false
  # argo_helm_enabled = true

  # self_managed = false

  helm_release_name = "argocd-helm"
  namespace         = "argocd-helm"

  argo_namespace = "default"
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}

################################################################################
# argocd helm deployment
################################################################################

resource "null_resource" "update_kubeconfig" {

  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
  }

  depends_on = [module.eks]
}





