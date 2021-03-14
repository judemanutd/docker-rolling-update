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
module "project_sg" {
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

# EC2 Instance
module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "${var.environment}-server"
  instance_count = 1

  # ami can be found from the aws console
  # use 099720109477 as the owner which is canonical and filter the version from there
  ami                     = "ami-02d8619fc5511c34e"
  instance_type           = "t3.nano"
  key_name                = module.key_pair.this_key_pair_key_name
  monitoring              = true
  vpc_security_group_ids  = [module.project_sg.this_security_group_id]
  subnet_ids              = module.project_vpc.public_subnets
  disable_api_termination = false

  root_block_device = [{
    volume_size = 30
  }]

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-aws"
  }
}

resource "aws_eip" "ip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = element(module.ec2_cluster.id, 0)
  allocation_id = aws_eip.ip.id
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = var.instance_public_key
}
