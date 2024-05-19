
# Resource: Create IAM Policy for cluster Auto scaler
resource "aws_iam_policy" "cluster_autoscaler_iam_policy" {
  name        = "${local.name}-AmazonEKS_Cluster_Autoscaler_Policy"
  path        = "/"
  description = "Cluster Autoscaler IAM Policy"
  #policy = data.http.ebs_csi_iam_policy.body
  policy = file("${path.module}/k8s-asg-policy.json") 
}


resource "aws_iam_role" "cluster_autoscaler_iam_role" {
  name = "${local.name}-cluster_autoscaler-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = var.oidc_provider_arn
        }

        Condition = {
          StringEquals = {
            "${join("/", slice(split("/", var.oidc_provider_arn), 1, 4))}:aud": "sts.amazonaws.com",            
            "${join("/", slice(split("/", var.oidc_provider_arn), 1, 4))}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }        

      },
    ]
  })

  tags = {
    tag-key = "${local.name}-cluster_autoscaler-iam-role"
  }
}

# Associate EBS CSI IAM Policy to EBS CSI IAM Role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.cluster_autoscaler_iam_policy.arn 
  role       = aws_iam_role.cluster_autoscaler_iam_role.name
}
