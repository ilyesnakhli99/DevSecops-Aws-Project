variable "aws_region" {
  type        = string
  description = "The AWS Region to deploy all infrastructure"
  default     = "eu-west-3" # Paris region (or choose your preferred region)
}

variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for the custom VPC network"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}