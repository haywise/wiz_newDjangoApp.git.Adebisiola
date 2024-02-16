provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "private_subnet_cidr_blocks" {}
variable "public_subnet_cidr_blocks" {}

data "aws_availability_zones" "available" {}

module "myApp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = "myApp-vpc"
  cidr                 = var.vpc_cidr_block
  private_subnets      = var.private_subnet_cidr_blocks
  public_subnets       = var.public_subnet_cidr_blocks
  azs                  = data.aws_availability_zones.available.names
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/myAppp-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myAppp-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myAppp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

resource "aws_lb" "myApp-alb" {
  name               = "myApp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.myApp-vpc.default_security_group_id]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  enable_http2                    = true
  idle_timeout                    = 60

  subnets = module.myApp-vpc.public_subnets
}

resource "aws_lb_target_group" "myApp-target-group" {
  name     = "myApp-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.myApp-vpc.vpc_id
}

resource "aws_lb_listener" "myApp-listener" {
  load_balancer_arn = aws_lb.myApp-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_ecr_repository" "myapp_ecr_repo" {
  name = "myapp-ecr-repo"
  # Additional configurations can be added here as needed
}
