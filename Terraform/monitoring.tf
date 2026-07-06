# 1. CREATE THE SNS NOTIFICATION TOPIC
resource "aws_sns_topic" "eks_alerts" {
  name = "eks-cpu-alerts"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 2. SUBSCRIBE YOUR EMAIL TO THE TOPIC
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.eks_alerts.arn
  protocol  = "email"
  endpoint  = "ilyesnakhlii188@gmail.com" # Your target email destination
}

# 3. CREATE THE CLOUDWATCH ALARM FOR HIGH CPU
resource "aws_cloudwatch_metric_alarm" "eks_cpu_alarm" {
  alarm_name          = "eks-worker-nodes-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60" # 1-minute tracking interval
  statistic           = "Average"
  threshold           = "70" # Trigger when CPU hits or passes 70%
  alarm_description   = "This alarm monitors the average CPU usage across EKS worker nodes."

  # Link the alarm directly to your automated SNS Topic ARN
  alarm_actions = [aws_sns_topic.eks_alerts.arn]

  # Target metric dimensions to catch your EKS compute layer
  # Change your dimensions block to match this layout:
  dimensions = {
    ClusterName = "aws_eks_cluster.main.name" #  Type your exact EKS Cluster Name here!
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}