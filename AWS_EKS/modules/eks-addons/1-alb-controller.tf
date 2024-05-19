# Datasource: AWS Load Balancer Controller IAM Policy get from aws-load-balancer-controller/ GIT Repo (latest)
# data "http" "lbc_iam_policy" {
#   #url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json"
#   # Optional request headers
#   request_headers = {
#     Accept = "application/json"
#   }
# }

# output "lbc_iam_policy" {
#   #value = data.http.lbc_iam_policy.body
#   value = data.http.lbc_iam_policy.response_body
# }

# Resource: Create AWS Load Balancer Controller IAM Policy 
resource "aws_iam_policy" "lbc_iam_policy" {
  name        = "${local.name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  #policy = data.http.lbc_iam_policy.body
  policy = file("${path.module}/ibc-role-policy.json")    
}

output "lbc_iam_policy_arn" {
  value = aws_iam_policy.lbc_iam_policy.arn 
}

# Resource: Create IAM Role 
# resource "aws_iam_role" "lbc_iam_role" {
#   name = "${local.name}-lbc-iam-role"

#   # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
#         }
#         Condition = {
#           StringEquals = {
#             "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:aud": "sts.amazonaws.com",            
#             "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }        
#       },
#     ]
#   })

#   tags = {
#     tag-key = "AWSLoadBalancerControllerIAMPolicy"
#   }
# }

## Added Value directly
resource "aws_iam_role" "lbc_iam_role" {
  name = "${local.name}-lbc-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${var.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${join("/", slice(split("/", var.oidc_provider_arn), 1, 4))}:aud": "sts.amazonaws.com",            
            "${join("/", slice(split("/", var.oidc_provider_arn), 1, 4))}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "AWSLoadBalancerControllerIAMPolicy"
  }
}

# Associate Load Balanacer Controller IAM Policy to  IAM Role
resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.lbc_iam_policy.arn 
  role       = aws_iam_role.lbc_iam_role.name
}

output "lbc_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value = aws_iam_role.lbc_iam_role.arn
}