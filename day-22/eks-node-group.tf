resource "aws_eks_node_group" "main_nodes" {
  cluster_name    = aws_eks_cluster.main_cluster.name
  node_group_name = "devops-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  
  # İşçileri (Pod'ları) güvenli private subnetlere koyuyoruz
  subnet_ids      = module.vpc.private_subnets

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2  # Başlangıçta 2 sunucu aç
    max_size     = 3  # Yük artarsa 3'e çık
    min_size     = 1  # Yük düşerse 1'e in
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_readonly,
  ]
}
