# 1. Create a Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH and Jenkins web traffic"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from anywhere (Crucial for your laptop and Ansible)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Jenkins Web UI access
  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules: Allow the servers to download updates, plugins, and talk to GitHub
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" means ALL protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# 2. Get the latest official Ubuntu 24.04 AMI ID dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu owner ID)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 3. Create the Jenkins Master EC2 Instance
resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"              # Cost-efficient but enough for Jenkins core
  subnet_id              = aws_subnet.public[0].id # Places it in the first Public Subnet
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # We will generate this SSH key pair later when deploying
  key_name = "ivolve-key"

  tags = {
    Name = "jenkins-master"
    Role = "JenkinsMaster" # Crucial tag for Ansible Dynamic Inventory later!
  }
}

# 4. Create the Jenkins Agent EC2 Instance
resource "aws_instance" "jenkins_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"              # Enough power to run Docker builds and Trivy scans
  subnet_id              = aws_subnet.public[1].id # Places it in the second Public Subnet
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "ivolve-key"

  tags = {
    Name = "jenkins-agent"
    Role = "JenkinsAgent" # Crucial tag for Ansible Dynamic Inventory later!
  }
}