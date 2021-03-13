provider "aws" {
  profile = var.profile
  region  = var.region
}

# VPC
module "project_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs            = [var.az]
  public_subnets = ["10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-aws"
  }

  vpc_endpoint_tags = {
    Terraform   = "true"
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-aws"
  }
}

# Security Groups
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${var.project_name}-security-group"
  vpc_id = module.project_vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "ssh-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all Outgoing"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = var.server_port
      to_port     = var.server_port
      protocol    = "tcp"
      description = "Server Port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
