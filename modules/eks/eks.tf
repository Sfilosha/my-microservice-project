resource "aws_iam_role" "eks" {
  name = "eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = var.kubernetes_version  # Optional: specify Kubernetes version
  
  vpc_config {
    endpoint_private_access = true   # Включає приватний доступ до API-сервера
    endpoint_public_access  = true   # Включає публічний доступ до API-сервера
    subnet_ids = var.subnet_ids      # Список підмереж, де буде працювати EKS
  }
}