# 1. Create the main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ivolve-custom-vpc"
  }
}

# 2. Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ivolve-igw"
  }
}

# 3. Dynamically discover available Availability Zones in your region
data "aws_availability_zones" "available" {
  state = "available"
}

# 4. Create Public Subnets (For Jenkins)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Automatically assigns public IPs to servers inside this subnet

  tags = {
    Name = "ivolve-public-subnet-${count.index + 1}"
  }
}

# 5. Create Private Subnets (For EKS Workers)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "ivolve-private-subnet-${count.index + 1}"
  }
}

# 6. Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "ivolve-public-rt"
  }
}

# 7. Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 8. Allocate a Static Public IP (Elastic IP) for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "ivolve-nat-eip"
  }
}

# 9. Create the NAT Gateway inside your first PUBLIC subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Sits in public subnet to access the IGW

  tags = {
    Name = "ivolve-nat-gw"
  }

  depends_on = [aws_internet_gateway.gw]
}

# 10. Create a Dedicated Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id # Routes traffic out through the NAT
  }

  tags = {
    Name = "ivolve-private-rt"
  }
}

# 11. Associate Private Subnets with the Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}