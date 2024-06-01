variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  default     = "aws-key-assignment"
}

variable "security_group_ingress_port" {
  description = "Port for security group ingress rules"
  default     = 80
}

variable "availability_zones" {
  description = "The list of availability zones to deploy resources in"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1c"]
}


variable "tag_name" {
  description = "Name tag for resources"
  default     = "portfolio"
}

