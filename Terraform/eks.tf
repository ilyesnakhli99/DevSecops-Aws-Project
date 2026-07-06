# ==============================================================================
# 1. IAM ROLES & POLICIES FOR THE EKS CONTROL PLANE
# ==============================================================================

resource "aws_iam_role" "eks_cluster_role" {
  name = "ivolve-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# Attach the standard Amazon managed policy for EKS clusters
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# ==============================================================================
# 2. THE EKS CONTROL PLANE (THE BRAINS)
# ==============================================================================

resource "aws_eks_cluster" "main" {
  name     = "ivolve-kubernetes-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # Kubernetes requirements state that a cluster MUST span at least two AZs.
    # We pass the IDs of the two Private Subnets we created in vpc.tf
    subnet_ids              = [aws_subnet.private[0].id, aws_subnet.private[1].id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# ==============================================================================
# 3. IAM ROLES & POLICIES FOR THE WORKER NODES
# ==============================================================================

resource "aws_iam_role" "eks_nodes_role" {
  name = "ivolve-eks-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Worker nodes need these three core policies to talk to EKS, EC2, and ECR registries
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "amazon_ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

# ==============================================================================
# 4. THE WORKER NODE GROUP (THE MUSCLE)
# ==============================================================================

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "ivolve-managed-nodes"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn

  # Deploy these instances deep inside the secure private subnets
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  instance_types = ["t3.medium"] # Smallest reliable size to run ArgoCD and your app together

  scaling_config {
    desired_size = 2 # Launches exactly 2 worker servers initially
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ecr_read_only,
  ]
}