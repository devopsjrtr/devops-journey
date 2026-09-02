resource "aws_eks_cluster" "main_cluster" {
  name     = "devops-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # EKS beyninin hem public hem private ağları görmesi gerekir
    subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}
